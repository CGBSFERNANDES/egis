--use egissql_317
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_lista_ncm_estado_imposto' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_lista_ncm_estado_imposto

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_lista_ncm_estado_imposto
-------------------------------------------------------------------------------
--pr_egis_relatorio_lista_ncm_estado_imposto
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
create procedure pr_egis_relatorio_lista_ncm_estado_imposto
@cd_relatorio int   = 0,
@cd_parametro int   = 0, 
@json nvarchar(max) = '' 


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
declare @ic_valor_comercial     varchar(10)
declare @cd_tipo_destinatario   int 
declare @cd_grupo_relatorio     int 
declare @cd_vendedor            int = 0
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

--set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
set @cd_empresa        = 0
set @cd_form           = 0
--set @cd_documento      = 0
--set @dt_usuario        = GETDATE()
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
---------------------------------------------------------------------------------------------------------------------
  select  
  
  @cd_vendedor      = isnull(cd_vendedor,0)
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

-- Obt�m a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
------------------------------

--select @dt_final
---------------------------------------------------------------------------------------------------------------------------------------------
--T�tulo do Relat�rio
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
            font-size: 75%;
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

--Procedure de Cada Relat?rio-------------------------------------------------------------------------------------  
  
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

--------------------------------------------------------------------------------------------------------------------------
--- select cliente

select 

--top 1 
--cf.*
 identity(int,1,1)                      as cd_controle,
 cf.cd_classificacao_fiscal             as Codigo,
 cf.cd_mascara_classificacao            as NCM,
 cf.nm_classificacao_fiscal             as Descricao,
 cf.pc_ipi_classificacao                as PcIPI,
 cf.ic_subst_tributaria                 as ST,
 cf.ic_base_reduzida                    as BaseReduzida,
 cf.ic_ativa_classificacao              as Ativa, 
 cf.cd_cest_classificacao               as CEST,
 cfe.cd_estado                          as CodigoEstado,
 e.sg_estado                            as UF,
 cfe.nm_classif_fiscal_estado           as Estado,
-- cfe.pc_icms_classif_fiscal,
-- cfe.pc_redu_icms_class_fiscal,
 --cfe.pc_icms_clas_fiscal               as '(%) icms',
 cfe.pc_icms_classif_fiscal             as Pcicms,
 cfe.pc_interna_icms_clas_fis           as PcIcmsInterna,
 cfe.pc_red_icms_clas_fiscal            as Redução,
 --cfe.nm_clas_fiscal_estado,
 --cfe.pc_iva_mi_classificacao,
 cfe.pc_icms_strib_clas_fiscal          as IVA_MVA,
 
 cfe.pc_red_st_icms_class_fiscal        as ReducaoST,

 cfe.ic_ipi_base_icms_st                as IPIBaseST, 
 cfe.ic_base_reduzida_estado            as BaseRedEstdo,
 cfe.ic_icms_pauta_classificacao        as Pauta,
 cfe.cd_pauta                           as Codigo_Pauta,
 cfe.pc_fundo_probreza                  as FundoPobreza

 into
 #NcmEstadoImposto


from 
  classificacao_fiscal cf
  left outer join classificacao_fiscal_estado cfe on cfe.cd_classificacao_fiscal = cf.cd_classificacao_fiscal
  left outer join estado e                        on e.cd_estado                 = cfe.cd_estado
  left outer join pauta_calculo_impostos p        on p.cd_pauta                  = cfe.cd_pauta
 
where
  cf.cd_classificacao_fiscal in ( select pf.cd_classificacao_fiscal from produto_fiscal pf
                                  inner join produto p on p.cd_produto = pf.cd_produto and isnull(p.ic_wapnet_produto,'N')='S'
								  where
								    pf.cd_classificacao_fiscal = cf.cd_classificacao_fiscal )
  and
  isnull(e.cd_estado,0)>0

order by
  cf.cd_mascara_classificacao,
  e.sg_estado
------------------------------------------------------------------------------------------------------------		 
   
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #NcmEstadoImposto  
  return  
 end  

--------------------------------------------------------------------------------------------------------------
declare @hr_inicial_consulta         nvarchar(10)
declare @nm_fantasia_vendedor        nvarchar(60)
declare @dt_consulta                 nvarchar(20)
declare @cd_consulta                 int = 0
declare @nm_tipo_pedido              nvarchar(60)
declare @cd_cliente_tb               nvarchar(20)
declare @nm_fantasia_cliente         nvarchar(60)
declare @vl_total_pedido             nvarchar(20)
declare @sg_estado_tb                nvarchar(20)
declare @nm_cidade_tb                nvarchar(60)
Declare @nm_condicao_pagamento_tb    nvarchar(40)
declare @nm_forma_pagamento          nvarchar(40)
DECLARE @vl_total_grupo              float = 0
DECLARE @qt_total                    float = 0
DECLARE @vl_total                    float = 0


select 
	@vl_total_grupo  = count(cd_controle)
from #NcmEstadoImposto

--------------------------------------------------------------------------------------------------------------
set @html_geral = '<div>
		<p class="section-title" style="text-align: center; padding: 8px;">Lista de NCM por Estado e Impostos</p>
	</div>
	<div>
    <table>  
    <tr class="tamanho">
        <th>Código</th>
        <th>NCM</th>
        <th>Descrição</th>
        <th>(%) IPI</th>
        <th>ST</th>
        <th>Base Reduzida</th>
        <th>Ativa</th>
        <th>CEST</th>
        <th>UF</th>
        <th>Estado</th>
        <th>(%) Icms</th>
        <th>(%) Icms interno</th>
        <th>Redução</th>
        <th>IVA_MVA</th>
        <th>(%) Redução ST</th>
        <th>IPI Base ST</th>
        <th>Base Red. Estado</th>
        <th>Pauta</th>
        <th>Codigo Pauta</th>
        <th>(%)Fundo Pobreza</th>
    </tr>'
					   
--------------------------------------------------------------------------------------------------------------
DECLARE @id int = 0 

WHILE EXISTS (SELECT TOP 1 cd_controle FROM #NcmEstadoImposto)
BEGIN
    SELECT TOP 1
        @id                          = cd_controle,

        @html_geral = @html_geral + 
        '<tr class="tamanho">
            <td>' + cast(ISNULL(Codigo, '') as nvarchar(15))+ '</td>
            <td>' + ISNULL(NCM, '') + '</td>
            <td style="text-align:left;">' + ISNULL(Descricao, '') + '</td>
            <td>' + CAST(ISNULL(PcIPI, '') AS NVARCHAR(10)) + '</td>
            <td>' + CAST(ISNULL(ST, '') AS NVARCHAR(10)) + '</td>
            <td>' + ISNULL(BaseReduzida, '') + '</td>
			<td>' + ISNULL(Ativa, '') + '</td>
			<td>' + CAST(ISNULL(CEST, '') AS NVARCHAR(10)) + '</td>
			<td>' + ISNULL(uf, '') + '</td>
			<td>' + ISNULL(Estado, '') + ' (' + CAST(ISNULL(CodigoEstado, '') AS NVARCHAR(10)) + ')</td>
			<td>' + CAST(ISNULL(Pcicms, '') AS NVARCHAR(10)) + '</td>
			<td>' + CAST(ISNULL(PcIcmsInterna, '') AS NVARCHAR(10)) + '</td>
			<td>' + CAST(ISNULL(Reducao, '') AS NVARCHAR(10)) + '</td>
			<td>' + CAST(ISNULL(IVA_MVA, '') AS NVARCHAR(10)) + '</td>
			<td>' + CAST(ISNULL(ReducaoST, '') AS NVARCHAR(10)) + '</td>
            <td>' + ISNULL(IPIBaseST, '') + '</td>
            <td>' + ISNULL(BaseRedEstdo, '') + '</td>
            <td>' + ISNULL(Pauta, '') + '</td>
            <td>' + CAST(ISNULL(Codigo_Pauta, '') AS NVARCHAR(10)) + '</td>
			<td>' + CAST(ISNULL(FundoPobreza, '') AS NVARCHAR(10)) + '</td>
        </tr>'
	  FROM #NcmEstadoImposto
    DELETE FROM #NcmEstadoImposto WHERE cd_controle = @id
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
      <p>Total: '+cast(isnull(@vl_total_grupo,0) as nvarchar(10))+'</p><br>
    </div>
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
--exec pr_egis_relatorio_lista_ncm_estado_imposto 231,''
------------------------------------------------------------------------------
