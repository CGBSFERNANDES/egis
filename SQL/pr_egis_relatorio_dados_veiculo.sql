IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_dados_veiculo' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_dados_veiculo

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_dados_veiculo
-------------------------------------------------------------------------------
--pr_egis_relatorio_dados_veiculo
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Joao Pedro Marcal
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis
--Data             : 10.01.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_dados_veiculo
@cd_relatorio int   = 0, 
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as
print 'iniciou a pr_egis_relatorio_dados_veiculo'
set @json = isnull(@json,'')
declare @cd_empresa                  int = 0,
        @cd_usuario                  int = 0,
        @cd_documento                int = 0,
        @dt_hoje                     datetime,
        @dt_inicial                  datetime,
        @dt_final                    datetime,
        @cd_ano                      int = 0 ,  
        @cd_mes                      int = 0 ,  
        @cd_dia                      int = 0,
        @cd_grupo_relatorio          int = 0,
        @cd_vendedor                 int = 0,
        @dt_base_incial              datetime,
        @dt_base_final               datetime,
        @html                        nvarchar(max) = '', --Total
        @html_empresa                nvarchar(max) = '', --Cabeçalho da Empresa
        @html_titulo                 nvarchar(max) = '', --Titulo
        @html_cab_det                nvarchar(max) = '', --Cabeçalho do Detalhe
        @html_detalhe                nvarchar(max) = '', --Detalhes
        @html_rod_det                nvarchar(max) = '', --Rodape do Detalhe
        @html_rodape                 nvarchar(max) = '', --Rodape
        @html_geral                  nvarchar(max) = '', --Geral
        @data_hora_atual             nvarchar(50)  = '',
        @cd_item_relatorio           int           = 0,  
        @nm_cab_atributo             varchar(100)  = '',
        @nm_dados_cab_det            nvarchar(max) = '',  
        @ic_produto_faturamento      char(1)       = '',
	    @cd_entregador               int = 0,
		@cd_veiculo                  int = 0

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
			@dt_pedido				    varchar(60) = '',
			@cd_cep_empresa			    varchar(20) = '',
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
			@cd_tipo_pedido             int = 0,
			@id                         int = 0, 
			@cd_pedido_entrega          VARCHAR(10), 
			@dt_pedido_entrega          DATETIME,
			@hr_entrega                 VARCHAR(10),
			@nm_tabela_preco            VARCHAR(100),
			@nm_fantasia_vendedor       VARCHAR(100),
			@nm_motivo_cancelamento     VARCHAR(255),
			@nm_empresa                 VARCHAR(100),
			@nm_condicao_pagamento      VARCHAR(100),
			@nm_fantasia_cliente        VARCHAR(100),
			@cd_cnpj_cliente            VARCHAR(20),
			@nm_razao_social_cliente    VARCHAR(100),
			@cd_cliente                 VARCHAR(10),
			@nm_endereco_cliente        VARCHAR(255),
			@cd_numero                  VARCHAR(20),
			@nm_bairro                  VARCHAR(100),
			@nm_complemento             VARCHAR(100),
			@nm_cidade_cliente          VARCHAR(100),
			@sg_estado_cliente          VARCHAR(10),
			@cd_numero_cliente          VARCHAR(20),
			@nm_contato                 VARCHAR(100),
			@vl_total_entrega           float = 0, 
			@ds_entrega                 VARCHAR(250),
			@nm_motorista               varchar(60),
			@nm_veiculo                 varchar(60),
			@nm_status_entrega          varchar(60),
			@nm_obs_entrega             varchar(250),
			@nm_itinerario              varchar(60),
			@nm_entregador              varchar(60),
			@qt_distancia_entrega       varchar(60) = '',
			@cd_romaneio                int  = 0,
			@dt_cancelamento            datetime
			
------------------------------------------------------------------------------------------------------
set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
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
  select @cd_documento           = valor from #json where campo = 'cd_documento'

   --set @cd_documento = isnull(@cd_documento,0)

   --if @cd_documento = 0
   --begin
   --  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
   --end

   if isnull(@cd_relatorio,0) = 0
   begin
     set @cd_relatorio = 364
   end

end

--------------------------------------------------------------------------------------------------------------------------
if isnull(@cd_empresa,0) = 0
begin
  set @cd_empresa       = dbo.fn_empresa()  
end
--------------------------------------------------------------------------------------------------------------------------
select  
  @titulo             = nm_relatorio,  
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)  
from  
  egisadmin.dbo.Relatorio  
where  
  cd_relatorio = @cd_relatorio  
--------------------------------------------------------------------------------------------------------------------------
--select  
--  @dt_inicial       = isnull(dt_inicial,''),
--  @dt_final         = isnull(dt_final,''),
--  @cd_documento     = isnull(cd_vendedor,0),
--  @cd_tipo_pedido   = ISNULL(cd_tipo_pedido,0),    
--  @cd_cliente       = ISNULL(cd_cliente,0)
--from   
--  Parametro_Relatorio  
  
--where  
--  cd_relatorio = @cd_relatorio  
--  and  
--  cd_usuario   = @cd_usuario  
----------------------------------------------------------------------------------------------------------------------------

set @cd_ano           = year(@dt_hoje)    
set @cd_dia           = day(@dt_hoje)
set @cd_mes           = month(@dt_hoje)
set @dt_base_incial   = dbo.fn_data_inicial(@cd_mes,@cd_ano)
set @dt_base_final    = dbo.fn_data_final(@cd_mes,@cd_ano)

if @dt_inicial is null  or @dt_inicial = '01/01/1900'    
begin      
      
  set @cd_ano = year(@dt_hoje)      
  set @cd_mes = month(@dt_hoje)      
      
  set @dt_inicial = dbo.fn_data_inicial(@cd_mes,@cd_ano)      
  set @dt_final   = dbo.fn_data_final(@cd_mes,@cd_ano)      
      
end   

------Dados da empresa-----------------------------------------------------------

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

-- Obtém a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
-------------------------------------------------------------------------------------------------


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
			margin-right:10px;
			
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
			font-size: 13px;
        }
        .header {
            padding: 5px;
            text-align: center;
        }
        .section-title {
            background-color: '+isnull(@nm_cor_empresa,'')+';
            color: white;
            padding: 5px;
            margin-bottom: 10px;
			border-radius:5px;
			font-size:14px;
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
            color: '+isnull(@nm_cor_empresa,'')+';
			font-size:14px;
        }
        .report-date-time {
            text-align: right;
            margin-bottom: 5px;
			margin-top:50px;
        }
		p {
			margin:5px;
			padding:0;
			font-size:12px
			}
	    .tamanho{
			font-size:12px;
			text-align:center;
		}
    </style>
</head>
<body>
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:30%; margin-right:20px">
			<img src="'+isnull(@logo,'')+'" alt="Logo da Empresa">
		</div>
		<div style="width:70%; padding-left:10px">
			<p class="title">'+isnull(@nm_fantasia_empresa,'')+'</p>
		    <p><strong>'+isnull(@nm_endereco_empresa,'')+', '+isnull(@cd_numero_endereco_empresa,'') + ' - '+isnull(@cd_cep_empresa,'')+ ' - '+isnull(@nm_cidade,'')+' - '+isnull(@sg_estado,'')+' - ' + isnull(@nm_pais,'') + '</strong></p>
		    <p><strong>Fone: </strong>'+isnull(@cd_telefone_empresa,'')+' - <strong>CNPJ: </strong>' + isnull(@cd_cnpj_empresa,'') + ' - <strong>I.E: </strong>' + isnull(@cd_inscestadual_empresa,'') + '</p>
		    <p>'+isnull(@nm_dominio_internet,'')+ ' - ' + isnull(@nm_email_internet,'')+'</p>
		</div>
    </div>'
  
select a.*, g.nm_grupo_relatorio into #RelAtributo   
from  
  egisadmin.dbo.Relatorio_Atributo a   
  inner join egisadmin.dbo.relatorio_grupo g on g.cd_grupo_relatorio = a.cd_grupo_relatorio  
where   
  a.cd_relatorio = @cd_relatorio  
  
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
 @nm_cab_atributo    = nm_cab_atributo
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

--------------------------------------------------------------------------------------------------------------------------

if @cd_veiculo = 0 
begin    
   if exists(select top 1 isnull(cd_entregador,0) from entregador where cd_usuario_entregador = @cd_usuario)    
   begin    
     select top 1
	   @cd_veiculo    = case when e.cd_veiculo > 0 then e.cd_veiculo else m.cd_veiculo end
     from        
       entregador e 
 	  left outer join motorista m on m.cd_motorista = e.cd_motorista
     where        
       e.cd_usuario_entregador = @cd_usuario        
   end    
   else    
   begin    
     set @cd_veiculo = 0    
   end    
end  

 
 set @cd_veiculo = ISNULL(@cd_veiculo,0)
--------------------------------------------------------------------------------------------------------------
  select 
     IDENTITY(int,1,1)                                               as cd_controle,
     cd_veiculo,						                             
     ltrim(rtrim(isnull(nm_veiculo,'')))                             as caption,
     isnull(v.cd_marca_veiculo,0)                                    as cd_marca_veiculo,
	 isnull(m.nm_marca_veiculo,'')                                   as percentual,
     isnull(v.cd_tipo_combustivel,0)                                 as cd_tipo_combustivel,
	 isnull(tc.nm_tipo_combustivel,'')                               as resultado2,
     isnull(v.aa_veiculo,0)                                          as badgeCaption,
     case when qt_km_atual_veiculo > 0 
	      then cast(isnull(v.qt_km_atual_veiculo,0) as varchar) + ' KM'
		  else ''
	 end                                                             as resultado1,
	 --366                                                           as cd_relatorio,
	 --cd_veiculo                                                    as cd_documento_form
     isnull(v.cd_placa_veiculo,'')                                   as resultado,
     isnull(v.cd_cor,0)                                              as cd_cor,
	 isnull(cv.nm_cor,'')                                            as resultado3,
     v.nm_modelo_veiculo,
     v.cd_documento_veiculo
	 into #ConsultaVeiculoEgismobRelatorio
  from veiculo v with(nolock)
  left outer join marca_veiculo     m with(nolock) on m.cd_marca_veiculo = v.cd_marca_veiculo
  left outer join Cor              cv with(nolock) on cv.cd_cor = v.cd_cor
  left outer join Tipo_Combustivel tc with(nolock) on tc.cd_tipo_combustivel = v.cd_tipo_combustivel
  
  where
    isnull(v.ic_ativo_veiculo,'N') = 'S'
	and
	v.cd_veiculo = case when @cd_veiculo = 0 then v.cd_veiculo else @cd_veiculo end
  order by
    nm_veiculo



set @html_geral = '<h1 style="text-align:center">Relatório de Veículos</h1>     
   <table>
     <tr>
	   <th style="font-size:12px;">Item</th>
       <th style="font-size:12px;">Veículo</th>
       <th style="font-size:12px;">Ano</th>
       <th style="font-size:12px;">KM</th>
       <th style="font-size:12px;">Placa</th>
       <th style="font-size:12px;">Cor</th>
	   <th style="font-size:12px;">Modelo</th>
    </tr>'
declare @cd_controle       int = 0, 
	    @caption           varchar(200) = '',
	    @percentual        varchar(200) = '',
	    @resultado2        varchar(200) = '',
	    @badgeCaption      varchar(200) = '',
	    @resultado1        varchar(200) = '',
	    @resultado         varchar(200) = '',
	    @resultado3        varchar(200) = '',
		@nm_modelo_veiculo varchar(200) = ''

DECLARE item_cursor CURSOR FOR
SELECT 
	cd_controle, 
	caption,
	percentual,
	resultado2,
	badgeCaption,
	resultado1,
	resultado,
	resultado3,
	nm_modelo_veiculo
FROM #ConsultaVeiculoEgismobRelatorio

OPEN item_cursor
FETCH NEXT FROM item_cursor INTO @cd_controle, @caption, @percentual, @resultado2, @badgeCaption, @resultado1, @resultado, @resultado3, @nm_modelo_veiculo

WHILE @@FETCH_STATUS = 0
BEGIN	
    SET @html_geral = @html_geral + '
        <tr>
			<td style="font-size:12px; text-align:center;width: 5%">'+isnull(cast(@cd_controle as varchar),'')+'</td>
            <td style="font-size:12px; text-align:center;width: 15%">'+isnull(@caption,'')+'</td>
			<td style="font-size:10px; text-align:center;width: 5%"><strong>'+isnull(@badgeCaption,'')+'</strong></td>
			<td style="font-size:12px; text-align:center;width: 15%">'+isnull(@resultado1,'')+'</td>
			<td style="font-size:12px; text-align:center;width: 15%">'+isnull(@resultado,'')+'</td>
			<td style="font-size:12px; text-align:center;width: 10%">'+isnull(@resultado3,'')+'</td>
			<td style="font-size:12px; text-align:center;width: 15%">'+isnull(@nm_modelo_veiculo,'')+'</td>
        </tr>'
    FETCH NEXT FROM item_cursor INTO  @cd_controle, @caption, @percentual, @resultado2, @badgeCaption, @resultado1, @resultado, @resultado3, @nm_modelo_veiculo
END

CLOSE item_cursor
DEALLOCATE item_cursor
					   
--------------------------------------------------------------------------------------------------------------

set @html_rodape =
	' </table>
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

select 'Veículos' AS pdfName,isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------
go

--exec pr_egis_relatorio_dados_veiculo 365,''


--exec pr_egis_relatorio_padrao '[{"cd_documento": 0, "cd_documento_form": 0, "cd_empresa": 351, "cd_item_documento_form": "0", "cd_item_processo": 0, "cd_menu": 8195, "cd_modulo": 0, "cd_parametro": 365, "cd_processo": 0, "cd_relatorio": 365, "cd_usuario": 4812, "dt_final": "07-24-2025", "dt_inicial": "07-24-2025"}]'