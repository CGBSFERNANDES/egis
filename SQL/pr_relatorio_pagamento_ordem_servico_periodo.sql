IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_pagamento_ordem_servico_periodo' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_pagamento_ordem_servico_periodo

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_ordem_servico_periodo
-------------------------------------------------------------------------------
--pr_relatorio_ordem_servico_periodo
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
create procedure pr_relatorio_pagamento_ordem_servico_periodo
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
			@nm_dominio_internet		varchar(200) = '',
			@tel_empresa                nvarchar(50) = ''



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
  select @cd_parametro           = valor from #json where campo = 'cd_parametro'
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_status              = valor from #json where campo = 'cd_status_ordem_servico'
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

select
  @dt_inicial       = dt_inicial,
  @dt_final         = dt_final,
  @cd_tecnico       = isnull(cd_tecnico,0),
  @cd_tipo_defeito  = isnull(cd_tipo_defeito,0),
  @cd_status        = isnull(cd_status_ordem_servico,0),
  @cd_marca_produto = isnull(cd_marca_produto,0)
from 
  Parametro_Relatorio

where
  cd_relatorio = @cd_relatorio
  and
  cd_usuario   = @cd_usuario

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
		@nm_dominio_internet		=  ltrim(rtrim(isnull(e.nm_dominio_internet,''))),
		@tel_empresa                =  isnull(e.cd_fax_empresa,'') 
			   
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
		    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - '+@tel_empresa+' <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
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

if isnull(@cd_parametro,0) = 2    
 begin    
  select * from #RelAtributo    
  return    
end    
--------------------------------------------------------------------------------------------------------------------------
select
  identity(int,1,1)                      as cd_controle,
  os.cd_ordem_servico                    as cd_ordem_servico,
  os.dt_ordem_servico                    as dt_ordem_servico,
  os.cd_cliente,
  os.cd_tecnico,
  os.ds_def_enc_ordem_servico            as ds_def_enc_ordem_servico,
  os.cd_marca_produto,
  case when isnull(osc.dt_pagamento,'') = '' 
  then '180' else dbo.fn_data_string(isnull(osc.dt_pagamento,'') + 180)  end    as dt_garantia,            
  os.hr_entrada_registro                 as hr_entrada_registro,
  os.nm_modelo_produto                   as nm_modelo_produto,
  os.ds_aspecto                          as ds_aspecto,
  isnull(os.vl_total_ordem_servico,0)    as vl_total_ordem_servico,
  dbo.fn_data_string(osc.dt_pagamento)   as dt_pagamento,

  --Cliente--
  c.nm_fantasia_cliente                  as nm_fantasia_cliente,
  c.nm_razao_social_cliente              as nm_razao_social_cliente,
  case when isnull(c.nm_fantasia_cliente,'') = ''
    then isnull(c.nm_razao_social_cliente,'') 
	else isnull(c.nm_fantasia_cliente,'') end as cliente,
  --Contato--
  case when isnull(os.cd_contato,0)>0 then
    cc.nm_contato_cliente
  else
    os.nm_contato_ap_ordem_serv
  end                                    as nm_contato_cliente,
  c.nm_endereco_cliente                  as nm_endereco_cliente,
  --Técnico
  t.nm_tecnico,

  --Status
  sos.nm_status_ordem_servico,

  --Defeito--
  td.nm_tipo_defeito,

  --Marca--
  mp.nm_marca_produto                        as nm_marca_produto,
  os.cd_numero_serie                         as cd_numero_serie,
  --Prioridade

  tp.nm_tipo_prioridade,
  dbo.fn_data_string(osc.dt_entrega) as dt_entrega,
  --Usuário
  u.nm_fantasia_usuario,
  os.dt_entrega_ordem_servico,
  os.ic_garantia_ordem_servico,
  cp.nm_condicao_pagamento,
  fp.nm_forma_pagamento,
  osc.vl_pagamento as vl_pagamento
  into
  #ordemServicoPeriodo

from
  Ordem_Servico os
  inner join cliente c                         on c.cd_cliente                = os.cd_cliente
  left outer join cliente_contato cc           on cc.cd_cliente               = os.cd_cliente and
                                                  cc.cd_contato               = os.cd_contato
  left outer join ordem_servico_orcamento osc  on osc.cd_ordem_servico        = os.cd_ordem_Servico
  left outer join marca_produto mp             on mp.cd_marca_produto         = os.cd_marca_produto
  left outer join tecnico t                    on t.cd_tecnico                = os.cd_tecnico
  left outer join tipo_defeito td              on td.cd_tipo_defeito          = os.cd_tipo_defeito_cliente
  left outer join egisadmin.dbo.usuario u      on u.cd_usuario                = os.cd_usuario
  left outer join tipo_prioridade tp           on tp.cd_tipo_prioridade       = os.cd_tipo_prioridade
  left outer join status_ordem_servico sos     on sos.cd_status_ordem_servico = os.cd_status_ordem_servico
  left outer join cliente_informacao_credito i on i.cd_cliente = c.cd_cliente
  left outer join condicao_pagamento cp        on cp.cd_condicao_pagamento = os.cd_condicao_pagamento
  left outer join forma_pagamento fp           on fp.cd_forma_pagamento    = case when isnull(osc.cd_forma_pagamento,0) = 0 then os.cd_forma_pagamento
                                                                           else
																		     osc.cd_forma_pagamento
																		   end


	where
	 osc.dt_pagamento between @dt_inicial and @dt_final
	 and
	 isnull(os.cd_status_ordem_servico,0) = case when isnull(@cd_status,0) = 0 then isnull(os.cd_status_ordem_servico,0) else isnull(@cd_status,0) end 
	 and 
	 isnull(os.cd_tecnico,0) = case when isnull(@cd_tecnico,0) = 0 then isnull(os.cd_tecnico,0) else isnull(@cd_tecnico,0) end
	 and 
	 isnull(os.cd_tipo_defeito_cliente,0) = case when isnull(@cd_tipo_defeito,0) = 0 then isnull(os.cd_tipo_defeito_cliente,0) else isnull(@cd_tipo_defeito,0) end
	 and
	 isnull(os.cd_marca_produto,0) = case when isnull(@cd_marca_produto,0) = 0 then isnull(os.cd_marca_produto,0) else isnull(@cd_marca_produto,0) end
	  and 
     isnull(osc.vl_pagamento,0) > 0 

	--select * from #ordemServicoPeriodo
--------------------------------------------------------------------------------------------------------------
declare @vl_total_os     float = 0
declare @vl_defeito      float = 0
declare @qt_defeito_dif  int = 0
declare @qt_status_dif   int = 0
declare @vl_status       int = 0
declare @qt_cliente      int = 0 
declare @qt_marca        int = 0 
declare @qt_ordem_os     int = 0 
select 
	@vl_total_os             = sum(vl_pagamento),
	@vl_defeito              = count(nm_modelo_produto),
	@vl_status               = count(nm_status_ordem_servico),
	@qt_marca                = count(nm_marca_produto),
	@qt_cliente              = count(cd_cliente),
	@qt_ordem_os             = count(cd_ordem_servico)
from #ordemServicoPeriodo

 if isnull(@cd_parametro,0) = 1    
 begin    
    select * from #ordemServicoPeriodo    
  return    
 end 

--------------------------------------------------------------------------------------------------------------
set @html_geral = '<div class="section-title">  
                        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
                        <p style="display: inline; text-align: center; padding: 15%;">'+isnull(@titulo,'')+'</p>  
                    </div> 
				   <table>
					   <tr>  
					    	<td class="tamanho" style="font-size: 110%;"><strong>Data Pagamento</strong></td> 
							<td class="tamanho" style="font-size: 110%;"><strong>Status</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Ordem Serviço<strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Cliente</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Defeito</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Marca</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Modelo</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Série</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Garantia</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Entrega</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Total Recebido $</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Forma Pagamento</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Técnico</strong></td>
					   </tr>'
					   	

--------------------------------------------------------------------------------------------------------------
declare @id int = 0
while exists ( select top 1 cd_controle from #ordemServicoPeriodo)
begin
	select top 1
		@id                         = cd_controle,

		@html_geral = @html_geral +'<tr>
						<td class="tamanho">'+isnull(dt_pagamento,'')+'</td>
						<td class="tamanho">'+isnull(nm_status_ordem_servico,0)+'</td>
						<td class="tamanho">'+cast(isnull(cd_ordem_servico,'')as nvarchar(20))+'</td>
						<td class="tamanho">'+isnull(nm_razao_social_cliente,'')+'</td>
						<td class="tamanho">'+isnull(nm_tipo_defeito,'')+'</td>
						<td class="tamanho">'+isnull(nm_marca_produto,'')+'</td>
						<td class="tamanho">'+isnull(nm_modelo_produto,'')+'</td>
						<td class="tamanho">'+cast(isnull(cd_numero_serie,0) as nvarchar(20))+'</td>
						<td class="tamanho">'+isnull(dt_garantia,'')+'</td>
						<td class="tamanho">'+isnull(dt_entrega,'')+'</td>
						<td class="tamanho">'+cast(isnull(dbo.fn_formata_valor(vl_pagamento),0) as nvarchar(10))+'</td>
						<td class="tamanho">'+isnull(nm_forma_pagamento,'')+'</td>
						<td class="tamanho">'+isnull(nm_tecnico,'')+'</td>
					  </tr>'
     from #ordemServicoPeriodo
	 delete from #ordemServicoPeriodo where cd_controle = @id
 end
--------------------------------------------------------------------------------------------------------------------
declare @html_totais nvarchar(max)=''
declare @titulo_total varchar(500)=''

set @html_rodape =
   ' <tr style="font-weight: bold;font-size: 20px;">
	 <td class="tamanho">Total</td>
	 <td class="tamanho">'+cast(isnull(@vl_status,0) as nvarchar(20))+'</td>
	 <td class="tamanho"></td>
	 <td class="tamanho"></td>
	 <td class="tamanho"></td>
	 <td class="tamanho"></td>
	 <td class="tamanho"></td>
	 <td class="tamanho"></td>
	 <td class="tamanho"></td>
	 <td class="tamanho"></td>
	 <td class="tamanho">'+cast(isnull(dbo.fn_formata_valor(@vl_total_os),0) as nvarchar(10))+'</td>
	 <td class="tamanho"></td>
	 <td class="tamanho"></td>
	 </tr>
	</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <div class="section-title">
		<p>Total de Ordem de Serviço: '+cast(isnull(@qt_ordem_os,0) as nvarchar(20))+'</p>
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
	@html_totais  + 
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
--exec pr_relatorio_pagamento_ordem_servico_periodo 246,'[{
--    "cd_empresa": "341",
--    "cd_modulo": "232",
--    "cd_menu": "0",
--    "cd_relatorio_form": 323,
--    "cd_processo": "",
--    "cd_form": 113,
--    "cd_documento_form": 26,
--    "cd_parametro_form": "2",
--    "cd_usuario": "4595",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "4595",
--    "dt_usuario": "2025-09-23",
--    "lookup_formEspecial": {},
--    "cd_parametro_relatorio": "26",
--    "cd_relatorio": "323",
--    "dt_inicial": "2025-09-01",
--    "dt_final": "2025-09-08",
--    "cd_status_ordem_servico": null,
--    "cd_tecnico": null,
--    "cd_marca_produto": null,
--    "cd_tipo_defeito": null,
--    "detalhe": [],
--    "lote": [],
--    "cd_documento": "26"
--}]' 
------------------------------------------------------------------------------

--select * from ordem_servico_orcamento where vl_pagamento > 0