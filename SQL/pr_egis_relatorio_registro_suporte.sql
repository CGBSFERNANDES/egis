IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_registro_suporte' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_registro_suporte

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_registro_suporte
-------------------------------------------------------------------------------
--pr_egis_relatorio_registro_suporte
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
create procedure pr_egis_relatorio_registro_suporte
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
Declare @cd_requisicao_inicial datetime 
declare @cd_requisicao_final   datetime
declare @cd_tipo_requisicao    int = 0
declare @cd_requisicao_compra  int = 0
declare @cd_status_requisicao  int = 0

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

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
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
-------------------------------------------------------------------------------------------------

select
  top 1
  @titulo      = nm_relatorio,
  @ic_processo = isnull(ic_processo_relatorio, 'N')
from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio

---------------------------------------------------------------------------------------------------------------------------

set @cd_ano           = year(@dt_hoje)    
set @cd_dia           = day(@dt_hoje)
set @cd_mes           = month(@dt_hoje)

----------------------------------------

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
	left outer join Pais p			with(nolock) on p.cd_pais    = e.cd_pais
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


-----------------------------------------------------------------------------------------------------------------------------------------
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
      padding: 20px;
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
      padding: 13px;
    }

    th {
      background-color: #f2f2f2;
      color: #333;
      text-align: left;
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
        <table>
            <tr>
                <td style="width: 20%; text-align: center;">
			       <img src="'+@logo+'" alt="Logo da Empresa">
			    </td>
				<td style="width: 60%; text-align: left;">
					<p class="title">'+@nm_fantasia_empresa+'</p>
					<p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
					<p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
					<p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
			</td>
				'

--select @html_empresa


--Detalhe--
--Procedure de Cada Relatório-------------------------------------------------------------------------------------

select
  a.*, 
  g.nm_grupo_relatorio 
into
  #RelAtributo 
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

--------------------------------------------------------------------------------------------------------------------------

Select
  identity(int,1,1)             as cd_controle,
  rs.cd_registro_suporte,  
  rs.nm_rs,
  rs.dt_registro_suporte,
  ps.nm_prioridade_suporte,
  ns.nm_nivel_suporte,
  m.sg_modulo, 
  me.nm_menu,
  f.nm_funcao,
  ss.nm_status_suporte,
  rs.cd_versao_modulo,
  c.nm_fantasia_cliente,
  cc.nm_fantasia_contato,
  cc.cd_email_contato_cliente,
  rs.dt_ocorrencia_suporte,
  rs.ds_ocorrencia_suporte,
  rs.ds_mensagem_suporte,
  rs.ds_observacao_suporte,
  rs.nm_doc_registro_suporte,
  rs.dt_solucao_registro,
  ci.nm_fantasia_consultor, 
  rs.nm_solucao_registro,
  rs.dt_solucao_dev,
  rs.ds_solucao,
  rs.dt_retorno_cliente,
  u.nm_fantasia_usuario,
  rs.dt_previsao_solucao
  into
  #Registro_Suporte
From
  Registro_Suporte rs 
  left outer join EGISADMIN.dbo.Menu me     on rs.cd_menu               = me.cd_menu  
  left outer join EGISADMIN.dbo.Modulo m    on rs.cd_modulo             = m.cd_modulo
  left outer join EGISADMIN.dbo.Funcao f    on rs.cd_funcao             = f.cd_funcao
  left outer join EGISADMIN.dbo.Usuario u   on rs.cd_usuario            = u.cd_usuario
  left outer join Consultor_Implantacao ci  on rs.cd_consultor          = ci.cd_consultor 
  left outer join Cliente c                 on rs.cd_cliente            = c.cd_cliente 
  left outer join Cliente_Contato cc        on rs.cd_cliente            = cc.cd_cliente and
                                               rs.cd_contato            = cc.cd_contato
  left outer join Prioridade_Suporte ps     on rs.cd_prioridade_suporte = ps.cd_prioridade_suporte
  left outer join Nivel_Suporte ns          on rs.cd_nivel_suporte      = ns.cd_nivel_suporte
  left outer join Status_Suporte ss         on rs.cd_status_suporte     = ss.cd_status_suporte
where
  rs.cd_registro_suporte = @cd_documento

  --SELECT * FROM #Registro_Suporte return
-------------------------------------------------------------------------------------------------------------- --
declare
	@nm_registro_usuario   varchar(100),
	@nm_fantasia_cliente   varchar(100),
	@nm_contato            varchar(100),
	@dt_previsao           datetime,
	@nm_consultor          varchar(100),
	@ds_ocorrencia_suporte varchar(300),
	@nm_nivel_suporte      varchar(100),
	@nm_prioridade         varchar(100),
	@nm_modulo             varchar(100),
	@nm_funcao             varchar(100),
	@nm_menu               varchar(100),
	@nm_usuario            varchar(100),
	@ds_mensagem_suporte   varchar(500),
	@dt_ocorrencia         datetime,
	@ds_observacao         varchar(300),
	@dt_baixa              datetime,
	@ds_solucao            varchar(500)

select 
  @nm_registro_usuario     = nm_rs,
  @nm_fantasia_cliente	   = nm_fantasia_cliente,
  @nm_contato			   = nm_fantasia_contato,
  @dt_previsao			   = dt_previsao_solucao,
  @nm_consultor			   = nm_fantasia_consultor,
  @ds_ocorrencia_suporte   = ds_ocorrencia_suporte,
  @nm_nivel_suporte        = nm_nivel_suporte,
  @nm_prioridade           = nm_prioridade_suporte,
  @nm_modulo               = sg_modulo,
  @nm_funcao               = nm_funcao,
  @nm_menu                 = nm_menu,
  @nm_usuario              = nm_fantasia_usuario,
  @ds_mensagem_suporte     = ds_mensagem_suporte,
  @dt_ocorrencia           = dt_ocorrencia_suporte,
  @ds_observacao           = ds_observacao_suporte,
  @dt_baixa                = dt_solucao_dev,
  @ds_solucao              = ds_solucao
from 
	#Registro_Suporte
--------------------------------------------------------------------------------------------------------------
set @html_geral = '<td style="width: 20%; text-align: center;">
        <p><strong>Data Hora:</strong> '+ISNULL(@data_hora_atual,'')+'</p>
        <p><strong>'+CAST(isnull(@cd_documento,0) as varchar(20))+'</strong></p>
        <p><strong>RS:</strong> '+ISNULL(@nm_registro_usuario,'')+'</p>
      </td>
    </tr>
  </table>
  <h2 class="section-title" style="text-align: center;">Registro de Suporte</h2>
  <table>
    <tr>
      <th>Cliente</th>
      <th>Contato</th>
      <th>Previsão</th>
      <th>Consultor</th>
    </tr>
    <tr>
      <td>'+ISNULL(@nm_fantasia_cliente,'')+'</td>
      <td>'+ISNULL(@nm_contato,'')+'</td>
      <td>'+ISNULL(dbo.fn_data_string(@dt_previsao),'')+'</td>
      <td>'+ISNULL(@nm_consultor,'')+'</td>
    </tr>
  </table>
  <table>
    <tr>
      <th>Titulo da Ocorrência</th>
      <th>Nivel</th>
      <th>Prioridade</th>
    </tr>
    <tr>
      <td>'+ISNULL(@ds_ocorrencia_suporte,'')+'</td>
      <td>'+ISNULL(@nm_nivel_suporte,'')+'</td>
      <td>'+ISNULL(@nm_prioridade,'')+'</td>
    </tr>
  </table>'			   	

--------------------------------------------------------------------------------------------------------------
--declare @id int = 0

--while exists ( select top 1 cd_controle from #reqCompraItem)
--begin

--	select top 1
--		@id                         = cd_controle,

--		@html_geral = @html_geral +'
--            <tr style="text-align: center;">
--                <td>'+cast(isnull(cd_controle,0) as nvarchar(20))+'</td>
--				<td>'+cast(isnull(cd_mascara_produto,0) as nvarchar(20))+'</td>
--				<td style="text-align: left;">'+isnull(nm_fantasia_produto,'')+' - '+isnull(nm_produto,'')+'</td>
--				<td>'+isnull(nm_marca_item_req_compra,'')+'</td>
--				<td>'+isnull(sg_unidade_medida,'')+'</td>
--                <td>'+cast(isnull(qt_item_requisicao_compra,0) as nvarchar(20))+'</td>
--				<td>'+cast(isnull(vl_custo_produto,'') as nvarchar(20))+'</td>
--                <td>'+isnull(dbo.fn_data_string(dt_item_nec_req_compra),'')+'</td>
--                <td>'+cast(isnull(qt_peso_req_compra,0) as nvarchar(20))+'</td>
--                <td>'+cast(isnull(qt_bruto_req_compra,0) as nvarchar(20))+'</td>
--                <td>'+cast(isnull(vl_custo_medio_produto,0) as nvarchar(20))+'</td>
--                <td>'+cast(isnull(cd_pedido_venda,0) as nvarchar(20))+'</td>
--                <td>'+cast(isnull(cd_item_pedido_venda,0) as nvarchar(20))+'</td>
--            </tr>'
--     from #reqCompraItem
--	 delete from #reqCompraItem where cd_controle = @id
-- end
 
--------------------------------------------------------------------------------------------------------------------
declare @html_totais nvarchar(max)=''
declare @titulo_total varchar(500)=''

set @html_rodape =
    '<table>
    <tr>
      <th>Módulo</th>
      <th>Função</th>
      <th>Menu</th>
      <th>Usúario</th>
    </tr>
    <tr>
      <td>'+ISNULL(@nm_modulo,'')+'</td>
      <td>'+ISNULL(@nm_funcao,'')+'</td>
      <td>'+ISNULL(@nm_menu,'')+'</td>
      <td>'+ISNULL(@nm_usuario,'')+'</td>
    </tr>
  </table>
  <table>
    <tr>
      <th>Ocorrência: '+ISNULL(dbo.fn_data_string(@dt_ocorrencia),'')+'</th>
    </tr>
    <tr>
      <td>'+ISNULL(@ds_mensagem_suporte,'')+'</td>
    </tr>
  </table>
  <table>
    <tr>
      <th>Observação</th>
    </tr>
    <tr>
      <td>'+ISNULL(@ds_observacao,'')+'</td>
    </tr>
  </table>
  '+case when ISNULL(@dt_baixa,'') <> '' then '
  <table>
    <tr>
      <th>Baixa: '+ISNULL(dbo.fn_data_string(@dt_baixa),'')+'</th>
    </tr>
    <tr>
      <td>'+ISNULL(@ds_solucao,'')+'</td>
    </tr>
  </table>'
  else ''
  end +'
  <p class="section-title" style="font-size: 16px;text-align: left;">Apontamento</p>
  <table>
    <tr>
      <th>Data</th>
      <th>Hora</th>
      <th>Observação</th>
      <th>Entrega</th>
      <th>Status</th>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
	<tr>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
	<tr>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </table>
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
--exec pr_egis_relatorio_registro_suporte 395,'' 
------------------------------------------------------------------------------

