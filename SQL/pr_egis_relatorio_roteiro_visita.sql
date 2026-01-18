IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_roteiro_visita' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_roteiro_visita

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_roteiro_visita
-------------------------------------------------------------------------------
--pr_egis_relatorio_roteiro_visita
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
create procedure pr_egis_relatorio_roteiro_visita
@cd_relatorio  int  = 0,
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')
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
DECLARE @id                     int = 0   
declare @cd_grupo_relatorio     int = 0 

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
			@cd_cep_empresa			    varchar(20) = '',			
			@nm_bairro					varchar(200) = '',
			@cd_numero_endereco			varchar(20) = '',
			@cd_telefone				varchar(20) = '',
			@ds_relatorio				varchar(8000) = '',
			@subtitulo					varchar(40)   = '',
			@footerTitle				varchar(200)  = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = '',  
            @cd_visita                  int = 0,    
            @ic_codigo_cliente          char(1) = 'N',  
            @ic_atraso_cliente          char(1) = 'N', 
		    @ic_ativo_cliente           char(1) = 'N',
		    -- Variáveis para os dados da tabela HTML
            @badgeCaption               VARCHAR(100),
            @dt_ultima_compra           datetime,
            @resultado2                 int,
            @dt_visita                  datetime,
            @caption                    VARCHAR(100),
            @nm_razao_social_cliente    VARCHAR(200),
            @nm_fantasia_vendedor       VARCHAR(200),
            @endereco                   VARCHAR(300),
            @Limite_Credito             DECIMAL(18,2),
            @Saldo                      DECIMAL(18,2),
            @nm_dia_semana              VARCHAR(20),
            @nm_criterio_visita         VARCHAR(100),
            @nm_condicao_pagamento      VARCHAR(100),
            @nm_tabela_preco            VARCHAR(100),
            @Telefone                   VARCHAR(20),
            @nm_ramo_atividade          VARCHAR(100),
            @cd_cnpj_cliente            VARCHAR(20),
			@cd_consulta                int = 0,
			@cd_pedido_venda            int = 0 

  



--------------------------------------------------------------------------------------------------------

set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
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
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'

   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'

   end
end

--set @cd_documento = 41724
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

select 

  @dt_inicial			  = case when isnull(@dt_inicial,'') = '' then dt_inicial else @dt_inicial end,    
  @dt_final				  = case when isnull(@dt_final,'') = '' then dt_final else @dt_final end   
  --@cd_documento			  = case when isnull(@cd_documento,'') = '' then cd_visita else @cd_documento end 
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
---------------------------
--Cabeçalho da Empresa
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
            padding: 20px;
            flex: 1;
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

        tr:nth-child(even) {
            background-color: #f9f9f9;
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
  
    
select * into #AuxRelAtributo from #RelAtributo    
where    
  cd_grupo_relatorio = @cd_grupo_relatorio    
    
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
    
if isnull(@cd_parametro,0) = 2    
 begin    
  select * from #RelAtributo    
  return    
end    
  
--------------------------------------------------------------------------------------------------------------------------
set @dt_hoje    = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)  
 
select
  top 1
  @ic_codigo_cliente = ISNULL(ic_codigo_cliente,'N'),
  @ic_atraso_cliente = isnull(ic_atraso_cliente,'N'),
  @ic_ativo_cliente  = isnull(ic_ativo_cliente,'N')
  --@ic_limite_credito = isnull(ic_limite_credito,'S')

from
  Config_EgisMob

set @ic_codigo_cliente = isnull(@ic_codigo_cliente,'N')


declare @cd_cliente_cnpj int = 0



select
  v.cd_cliente
into
  #ListaClientesRel
from
  visita v with (nolock) 
  left outer join cliente c                   with (nolock) on c.cd_cliente					= v.cd_cliente
  inner join status_cliente sc                with (nolock) on sc.cd_status_cliente			= c.cd_status_cliente
where
  v.cd_visita = @cd_documento
  and 
  isnull(sc.ic_analise_status_cliente,'N')='S'

order by
  v.dt_visita, 
  v.cd_vendedor 
  

--Ativos
select top 0 
  0                         as cd_cliente,
  0                         as qt_ativo,
  cast('' as varchar(120))  as nm_ultimo_bem
into
  #AtivoRel




select top 0 
  0 as cd_cliente,
  cast(0.00 as float) as vl_total_atraso
into
  #ClienteAtrasoRel

if @ic_atraso_cliente = 'S'
begin
  insert into #ClienteAtrasoRel
  select
     dr.cd_cliente,
     cast(str(sum(isnull(dr.vl_saldo_documento,0) - isnull(dr.vl_abatimento_documento,0)),25,2) as float) as vl_total_atraso
  from
     #ListaClientesRel lc with (nolock) 
	 left outer join Documento_receber dr with (nolock) on dr.cd_cliente = lc.cd_cliente
  where
     dr.dt_vencimento_documento <= dbo.fn_dia_util (getdate()-1,'N','U') 
	 and
     CAST(isnull(dr.vl_saldo_documento,0) - isnull(dr.vl_abatimento_documento,0) AS DECIMAL(25,2)) > 0.001
     and 
	 dr.dt_cancelamento_documento is null
     and 
	 dr.dt_devolucao_documento is null
     and 
	 isnull(dr.cd_tipo_destinatario,1)=1
  group by
     dr.cd_cliente
end

  
if @ic_ativo_cliente = 'S'
begin
select   
  cd_cliente,  
  cd_bem,
  max(dt_registro_bem) as dt_registro_bem 
into
  #Ultimo_Mov_Bem_ClienteRel
from  
  registro_movimento_bem   
group by  
  cd_cliente,  
  cd_bem


select 
  rmb.cd_cliente,  
  rmb.cd_bem,  
  rmb.cd_tipo_movimento_bem,  
  rmb.dt_registro_bem,
  b.nm_bem
into
  #Consulta_Final_AtivoRel
from
  registro_movimento_bem rmb
  inner join #Ultimo_Mov_Bem_ClienteRel u on u.cd_cliente      = rmb.cd_cliente
                                      and u.cd_bem          = rmb.cd_bem
                                      and u.dt_registro_bem = rmb.dt_registro_bem
  left outer join Bem b                on b.cd_bem          = rmb.cd_bem
where
  rmb.cd_tipo_movimento_bem = case when @cd_empresa in (329,340) then 6 else 1 end

  insert into #AtivoRel
  select   
    isnull(cd_cliente,0),   
    COUNT(distinct cd_bem) as qt_ativo,
	max(nm_bem)            as nm_ultimo_bem
  from #Consulta_Final_AtivoRel with(nolock)  
  where   
    cd_cliente = case when isnull(@cd_cliente_cnpj,0) > 0 then @cd_cliente_cnpj else cd_cliente end
  group by  
    cd_cliente 

end



select
  case when isnull(v.hr_inicio_visita,'') <> '' and isnull(vb.cd_visita,0) = 0
	   then 'Check-in' 
	   when isnull(vb.cd_visita,0) > 0
	   then 'Check-out'
	   else 'Em Aberto'
  end																as 'badgeCaption',
 ISNULL((
  SELECT MAX(vw.dt_nota_saida)
  FROM vw_faturamento_bi vw
  WHERE vw.cd_cliente = v.cd_cliente
), '')                                                              AS dt_ultima_compra,
  case when isnull(atv.qt_ativo,0) > 0
	   then convert(varchar,atv.qt_ativo)
	   else ''
  end	                                                            as qt_ativo,
  vb.cd_visita                                                      as baixa,

  identity(int,1,1)                                                 as cd_controle, 
  convert(varchar,isnull(c.dt_cadastro_cliente,''),103)             as dt_cadastro_cliente,
  v.cd_visita,
  v.dt_visita as dt_visita,
  v.cd_cliente,
  v.cd_vendedor,
  vb.dt_baixa_visita, --Não mexer nesse campo, clonar e usar outro alias
  case when isnull(convert(varchar,vb.dt_baixa_visita,103),'') <> ''
       then 'Baixa: ' + isnull(convert(varchar,vb.dt_baixa_visita,103),'') 
	   else ''
  end                                                               as resultado5,
  case when isnull(convert(varchar,vb.dt_baixa_visita,103),'') <> ''
       then 'Baixa: ' + isnull(convert(varchar,vb.dt_baixa_visita,103),'') 
	   else ''
  end                                                               as 'status',
  p.nm_fantasia_vendedor,
  c.nm_razao_social_cliente,
  c.nm_fantasia_cliente,
  c.cd_cep,
  cc.nm_contato_cliente,
  v.nm_assunto_visita,
  rv.dt_chegada_local_visita,
  rv.dt_saida_local_visita,
  case when vb.dt_baixa_visita is not null 
       then 1
       else case when rv.dt_chegada_local_visita is not null or isnull(v.ic_local_visita,'N')='S' 
	             then 2
                 else 0
            end
  end                                                                as ic_visita,

  case when rv.dt_saida_local_visita   is null then 0 else 1 end as ic_saida_visita,

  isnull(gcc.nm_grupo_categ_cliente,'')                              as 'Canal',
  ltrim(rtrim(isnull(c.nm_fantasia_cliente,''))) 
  +
  case when @ic_codigo_cliente='S'
       then ' ('+ltrim(rtrim(CAST(c.cd_cliente as varchar(9))))+')'
       else ''
  end                                                                as 'caption',
  'Visita: ' + cast(v.cd_visita as varchar) + ' | '  
   + ltrim(rtrim(isnull(c.nm_razao_social_cliente,'')))                as 'resultado',
  CASE WHEN LTRIM(RTRIM(ISNULL(gcc.nm_grupo_categ_cliente,''))) = '' AND LTRIM(RTRIM(ISNULL(cac.nm_categoria_cliente,''))) = ''
	   THEN ''
	   ELSE LTRIM(RTRIM(ISNULL(gcc.nm_grupo_categ_cliente,''))) + '-Segmento: ' + LTRIM(RTRIM(ISNULL(cac.nm_categoria_cliente,''))) +
	     CASE WHEN @cd_parametro = 0 
			  THEN '-' + LTRIM(RTRIM(p.nm_fantasia_vendedor))  
			  ELSE '' 
		 END                                                         
  END                                                                 AS 'quantidade',

-- Status do Card------------------------------------------------------------------------------------------------------------------------------------------------------
case 
	WHEN 
	    (SELECT format(max(vw.dt_nota_saida),'MMyyyy','pt-br') 
	     FROM vw_faturamento_bi vw with (nolock)
	     WHERE vw.cd_cliente = c.cd_cliente) = format(@dt_hoje,'MMyyyy','pt-br')
	     THEN '#21BA45' -----------------------------------------------------------------------------Verde  
	else
		case 
			WHEN isnull(cic.vl_saldo_credito_cliente,0) <= 0 THEN '#C12612' ---------------------------------Vermelho
	else
		CASE 
			WHEN 
				isnull(cic.vl_saldo_credito_cliente,0) > 0 
				and
				(SELECT max(vw.dt_nota_saida)
				FROM vw_faturamento_bi vw with (nolock)
				WHERE vw.cd_cliente = c.cd_cliente) is null
				THEN '#1976D2' ----------------------------------------------------------------------------Azul
	
	else	 
		case 
			WHEN 
				(SELECT format(max(vw.dt_nota_saida),'MMyyyy','pt-br') 
				 FROM vw_faturamento_bi vw with (nolock)
				 WHERE vw.cd_cliente = c.cd_cliente) < format(@dt_hoje,'MMyyyy','pt-br') 
				 THEN '#F2C037' -----------------------------------------------------------------------------Amarelo
    ELSE '' 
	end 
	end 
	end
END AS badgeStatus,
------------------------------------------------------------------------------------------------------------------------------------------------------

   ''																								as 'subcaption1',
   'S'																								as  'ic_sub_menu',
 CONCAT(SUBSTRING(c.cd_cep, 1, 5), '-', SUBSTRING(c.cd_cep, 6, 3)) +  ' ' + 
    LTRIM(RTRIM(c.nm_endereco_cliente)) + ', ' +
    LTRIM(RTRIM(c.cd_numero_endereco)) + ' - ' +
    LTRIM(RTRIM(c.nm_bairro)) + ' ' +
    LTRIM(RTRIM(cid.nm_cidade)) + '/' +
    LTRIM(RTRIM(est.sg_estado))                                                                 AS 'endereco',
    'Última Compra: ' + convert(varchar,(select max(vw.dt_nota_saida)
    from
      vw_faturamento_bi vw
    where
      vw.cd_cliente = v.cd_cliente),103)                                                        as 'resultado1',
	isnull(LTRIM(RTRIM(c.nm_bairro)),'')														as nm_bairro,
	isnull(LTRIM(RTRIM(cid.nm_cidade)),'')												    	as nm_cidade,
	isnull(LTRIM(RTRIM(est.sg_estado)),'')												    	as sg_estado,
	'('+ltrim(rtrim(c.cd_ddd))+') '+ltrim(rtrim(c.cd_telefone))							    	as 'Telefone',
	isnull(ci.vl_limite_credito_cliente,0)					                                	as 'Limite_Credito',
	isnull(ci.vl_saldo_credito_cliente,0)					    	                            as Saldo,
	convert(varchar,isnull(ci.pc_desconto_boleto,0)) + '%'								        as pc_desconto_boleto,
	convert(varchar,isnull(c.pc_desconto_cliente,0)) + '%'										as pc_desconto_cliente,
	ltrim(rtrim(isnull(s.nm_semana,0)))															as nm_dia_semana,
	isnull(rc.nm_criterio_visita,'')															as nm_criterio_visita,
	ltrim(rtrim(isnull(cp.nm_condicao_pagamento,'')))											as nm_condicao_pagamento,
	isnull(tp.nm_tabela_preco,'')																as nm_tabela_preco,
	isnull(cac.nm_categoria_cliente,'')															as nm_categoria_cliente,
	isnull(ra.nm_ramo_atividade,0)																as nm_ramo_atividade,
	ltrim(rtrim(isnull(cg.nm_cliente_grupo,'')))												as nm_cliente_grupo,
	isnull(cr.nm_cliente_regiao,'')																as nm_cliente_regiao,
	isnull(c.nm_complemento_endereco,'')														as nm_complemento_endereco,
	rtrim(ltrim(c.nm_endereco_cliente))+', '+rtrim(ltrim(c.cd_numero_endereco))					as nm_endereco_cliente,



	case 
		when ci.dt_suspensao_credito is not null or isnull(ci.ic_bloqueio_total_cliente,'N') = 'S' or isnull(ci.ic_bloqueio_faturamento,'N') = 'S' then 'Crédito Suspenso'
			else  
				case 
				when isnull(ci.vl_saldo_credito_cliente,0) <= 0 then 'Sem Limite Crédito'
				else 
				case 
				when isnull(vw.vl_saldo_documento,0) > 0 then 'Atraso'
				else 'Liberado'
				end
			end 
		end as Credito,
	
	
	 case when isnull(atv.qt_ativo,0) > 0
		then convert(varchar,atv.qt_ativo)
		else ''
		end																						as 'resultado2',

		isnull(ca.vl_total_atraso,0) as vl_total_atraso,
		
	case when isnull(ca.vl_total_atraso,0) <= 0 and isnull(cic.vl_saldo_credito_cliente,0) > 0
	     then 'Crédito: R$ ' + dbo.fn_formata_valor(isnull(cic.vl_saldo_credito_cliente,0))
		 else ''
	end
	--+
	--case when isnull(tp.sg_tabela_preco,'')  <> '' and @ic_limite_credito = 'S' and isnull(ca.vl_total_atraso,0) > 0  
 --        then ' - '  
 --        else ''  
 --   end  
    +  
    case when isnull(ca.vl_total_atraso,0) > 0  
         then 'ATRASO R$: '+ dbo.fn_formata_valor(isnull(ca.vl_total_atraso,0))   
         else ''  
    end                                                                                       as 'resultado3',
	isnull(tp.nm_tabela_preco,'') + 
		case when isnull(v.cd_vendedor,'') > 0 and isnull(tp.nm_tabela_preco,'') <> ''
			 then ' - ' + p.nm_vendedor
			 else ''
		end	+
	case when isnull(c.cd_semana,0) > 0 
		 then ' - ' + s.nm_semana
		 else '' 
	end																							as  'resultado4',

	c.nm_fantasia_cliente																		as 'searchLabel',
	
  isnull(cac.nm_categoria_cliente,'')													        as 'Segmento',
  ''																							as 'iconFooter1',
  'S'																							as 'filterMenu',						
  ltrim(rtrim(isnull(gcc.nm_grupo_categ_cliente,'')))+
  '-Segmento: '+ltrim(rtrim(isnull(cac.nm_categoria_cliente,''))) +case when @cd_parametro=0 then  '-'+ltrim(rtrim(p.nm_fantasia_vendedor))  else '' end                                
                                                                     as 'VendedorSegmento',

  --Endereço--------------------------------------------------------------------
  ltrim(rtrim(c.nm_endereco_cliente))+', '+ltrim(rtrim(c.cd_numero_endereco))+ ' - '+ ltrim(rtrim(c.nm_bairro)) + ' '+
  ltrim(rtrim(cid.nm_cidade)) + '/'+ltrim(rtrim(est.sg_estado))
  as 'Local',
   
  ( select max(vw.dt_pedido_venda)
    from
      vw_venda_bi vw
    where
      vw.cd_cliente = v.cd_cliente and
      vw.dt_cancelamento_item is null
   )                                                                                                                     as 'dt_ultima_compra_pedido',



  isnull(vw.vl_saldo_documento,0)																						as vl_atraso,
  dbo.fn_formata_cnpj(isnull(c.cd_cnpj_cliente,''))																		as cd_cnpj_cliente,
  isnull(cv.cd_consulta,0)                                                                                              as cd_consulta,
  isnull(pv.cd_pedido_venda,0)                                                                                          as cd_pedido_venda



into
  #VisitaRel
from
  visita v with (nolock) 
  left outer join visita_baixa vb             with (nolock) on vb.cd_visita					= v.cd_visita
  left outer join vendedor p                  with (nolock) on p.cd_vendedor				= v.cd_vendedor
  left outer join cliente c                   with (nolock) on c.cd_cliente					= v.cd_cliente
  left outer join semana s					with (nolock)   on s.cd_semana			 = c.cd_semana

  left outer join cliente_contato cc          with (nolock) on cc.cd_cliente				= v.cd_cliente and
                                                               cc.cd_contato				= v.cd_contato
  left outer join Tabela_Preco tp           with (nolock)   on tp.cd_tabela_preco = case when isnull(c.cd_tabela_preco,0)>0 
																						then c.cd_tabela_preco
																					else
																					    p.cd_tabela_preco
																					end
  left outer join cliente_informacao_credito ci with (nolock) on ci.cd_cliente            = c.cd_cliente

  left outer join registro_visita rv          with (nolock) on rv.cd_visita					= v.cd_visita
  left outer join Visita_Diversos vd          with (nolock) on vd.cd_visita					= v.cd_visita
  left outer join Categoria_Cliente cac       with (nolock) on cac.cd_categoria_cliente		= c.cd_categoria_cliente
  left outer join Grupo_Categoria_Cliente gcc with (nolock) on gcc.cd_grupo_categ_cliente	= cac.cd_grupo_categoria_cli
  inner join status_cliente sc                with (nolock) on sc.cd_status_cliente			= c.cd_status_cliente
  left outer join vw_atraso_cliente vw        with (nolock) on vw.cd_cliente				= c.cd_cliente
  left outer join Pais    pa                  with (nolock) on pa.cd_pais                   = c.cd_pais
  left outer join estado est                  with (nolock) on est.cd_pais                  = pa.cd_pais 
                                                           and est.cd_estado				= c.cd_estado
  left outer join cidade cid                  with (nolock) on cid.cd_pais                  = pa.cd_pais
                                                           and cid.cd_estado                = est.cd_estado
                                                           and cid.cd_cidade				= c.cd_cidade 
  left outer join Cliente_Informacao_Credito cic with (nolock) on cic.cd_cliente			= c.cd_cliente
  left outer join #AtivoRel                     atv with (nolock) on atv.cd_cliente			= c.cd_cliente 
  left outer join criterio_visita			  rc with (nolock) on rc.cd_criterio_visita		= c.cd_criterio_visita
  left outer join condicao_pagamento         cp with (nolock) on cp.cd_condicao_pagamento = c.cd_condicao_pagamento
  left outer join ramo_atividade				ra  with (nolock) on ra.cd_ramo_atividade = c.cd_ramo_atividade
  left outer join Cliente_Grupo				cg with (nolock) on cg.cd_cliente_grupo = c.cd_cliente_grupo
  left outer join Cliente_Regiao			  cr with (nolock) on cr.cd_cliente_regiao		= c.cd_regiao
  left outer join #ClienteAtrasoRel ca             with(nolock) on ca.cd_cliente = c.cd_cliente
  left outer join Consulta_Visita cv             with(nolock) on cv.cd_visita = v.cd_visita
  left outer join Pedido_Venda    pv             with(nolock) on pv.cd_consulta = cv.cd_consulta
 

where
  v.cd_visita = @cd_documento
  and isnull(sc.ic_analise_status_cliente,'N')='S'

order by
  v.dt_visita, v.cd_vendedor


----------------------------------------------------------------------------------------------------------      
 --if isnull(@cd_parametro,0) = 1    
 --begin    
 --   select * from #PositivacaoCliente    
 -- return    
 --end 
----------------------------------------------------------------------------------------------------------
select
	 @badgeCaption              = badgeCaption,           
	 @dt_ultima_compra       	= dt_ultima_compra,       
	 @resultado2             	= resultado2,            
	 @dt_visita              	= dt_visita,              
	 @caption                	= caption,                
	 @nm_razao_social_cliente	= nm_razao_social_cliente,
	 @nm_fantasia_vendedor   	= nm_fantasia_vendedor,   
	 @endereco               	= endereco,               
	 @Limite_Credito         	= Limite_Credito,         
	 @Saldo                  	= Saldo,                  
	 @nm_dia_semana          	= nm_dia_semana,          
	 @nm_criterio_visita    	= nm_criterio_visita,    
	 @nm_condicao_pagamento  	= nm_condicao_pagamento,  
	 @nm_tabela_preco        	= nm_tabela_preco,        
	 @Telefone               	= Telefone,               
	 @nm_ramo_atividade      	= nm_ramo_atividade,      
	 @cd_cnpj_cliente        	= cd_cnpj_cliente,
	 @cd_pedido_venda           = cd_pedido_venda,
	 @cd_consulta               = cd_consulta
from #VisitaRel 
----------------------------------------------------------------------------------------------------------

set @html_geral ='
    <div class="section-title">   
       <p style="text-align: center;">'+case when isnull(@titulo,'') <> '' then ''+isnull(@titulo,'')+'' else 'Roteiro de Visita' end +' '+CAST(isnull(@cd_documento,'')as nvarchar(20))+'</p>  
    </div>
    <div>
	  <table class="tamanho">
	    <tr>
            <th>Data Visita</th>
            <td>'+isnull(dbo.fn_data_string(@dt_visita),'')+'</td>
        </tr>
	    <tr>
            <th>Cliente</th>
            <td>'+isnull(@caption,'')+'</td>
        </tr>
        <tr>
            <th>Razão Social</th>
            <td>'+isnull(@nm_razao_social_cliente,'')+'</td>
        </tr>
		<tr>
            <th>CNPJ</th>
            <td>'+isnull(@cd_cnpj_cliente,'')+'</td>
        </tr> 
	    <tr>
            <th>Telefone</th>
            <td>'+isnull(@Telefone,'')+'</td>
        </tr>
		
        <tr>
            <th>Endereço</th>
            <td>'+isnull(@endereco,'')+'</td>
        </tr>
		<tr>
            <th>Vendedor</th>
            <td>'+isnull(@nm_fantasia_vendedor,'')+'</td>
        </tr>

        <tr>
            <th>Última Compra</th>
            <td>'+isnull(dbo.fn_data_string(@dt_ultima_compra),'')+'</td>
        </tr>
	    <tr>
            <th>Dia da Semana</th>
            <td>'+isnull(@nm_dia_semana,'')+'</td>
        </tr>
        <tr>
            <th>Critétrio Semanal</th>
            <td>'+isnull(@nm_criterio_visita,'')+'</td>
        </tr>
        <tr>
            <th>Ativos</th>
            <td>'+cast(isnull(@resultado2,'') as nvarchar(20))+'</td>
        </tr>
        <tr>
            <th>Limite de Crédito</th>
            <td>R$ '+cast(isnull(dbo.fn_formata_valor(@Limite_Credito),'')as nvarchar(20))+'</td>
        </tr>
        <tr>
            <th>Saldo</th>
            <td>R$ '+cast(isnull(dbo.fn_formata_valor(@Saldo),'')as nvarchar(20))+'</td>
        </tr>
 
        <tr>
            <th>Condição de Pagamento</th>
            <td>'+isnull(@nm_condicao_pagamento,'')+'</td>
        </tr>     
        <tr>
            <th>Tabela de Preço</th>
            <td>'+isnull(@nm_tabela_preco,'')+'</td>
        </tr>

        <tr>
            <th>Segmento de Mercado</th>
            <td>'+isnull(@nm_ramo_atividade,'')+'</td>
        </tr>

		 <tr>
            '
			     +case when isnull(@cd_pedido_venda,0) > 0 
				  then '<th>Pedido Venda</th>'
			       when isnull(@cd_consulta,0) > 0
				   then '<th>Consulta</th>'
				   Else '' end +'
		    
           
		   '
		         +case when isnull(@cd_pedido_venda,0) > 0 
			       then'<td>'+ cast(isnull(@cd_pedido_venda,0) as nvarchar(20))+'</td>' 
				   when isnull(@cd_consulta,0) > 0 then '<td>'+cast(isnull(@cd_consulta,0) as nvarchar (20))+'</td>'
				   else '' end +'
	       
        </tr> 
		
    </table>
'
--------------------------------------------------------------------------------------------------------------

set @html_rodape =
    '
	</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
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
--select isnull(@html,'') as RelatorioHTML

select 'VisitaComercial_'+CAST(isnull(@cd_documento,'')as varchar)+'' AS pdfName,isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go


------------------------------------------------------------------------------
--exec pr_egis_relatorio_roteiro_visita 307,'' 
------------------------------------------------------------------------------


