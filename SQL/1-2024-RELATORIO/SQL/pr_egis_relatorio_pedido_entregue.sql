IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_pedido_entregue' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_pedido_entregue

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_pedido_entregue
-------------------------------------------------------------------------------
--pr_egis_relatorio_pedido_entregue
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
create procedure pr_egis_relatorio_pedido_entregue
@cd_relatorio int   = 0, 
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as
print 'iniciou a pr_egis_relatorio_pedido_entregue'
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
        @vl_meta                     decimal(25,2) = 0.00,
        @vl_total                    decimal(25,2) = 0.00,
        @pc_atingido                 decimal(25,2) = 0.00,
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
        @qt_total                    INT           = 0

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

   set @cd_documento = isnull(@cd_documento,0)

   --Não retirar nenhum dos ifs abaixo, é usado no Egismob
   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento_form'
   end

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_pedido_venda'
   end

   if isnull(@cd_relatorio,0) = 0
   begin
     set @cd_relatorio = 324
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
  --@ic_processo        = isnull(ic_processo_relatorio, 'N'),  
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
			padding:20px
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
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
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
  select   
identity(int,1,1)                                                              as cd_controle,  
    pe.cd_pedido_entrega                                                           as cd_consulta,  
    pe.dt_pedido_entrega                                                           as dt_pedido_entrega,  
 c.nm_fantasia_cliente                                                          as nm_fantasia_clientex,  
 pe.vl_total_entrega                           as vl_total_entrega,  
 'No. ' + cast(pe.cd_pedido_entrega as varchar)   
   + ' - ' + ltrim(rtrim(isnull(cc.nm_fantasia_contato,'')))                    as nm_contato_cliente,  
 'Entrega'                                                                      as nm_status,  
 isnull(pe.qt_entrega,0)                                                        as qt_produto,  
 pe.cd_vendedor                                                                 as cd_vendedor,  
 pe.cd_pedido_entrega                                                           as cd_pedido_entrega,  
 isnull(pe.qt_entrega,0)                                                        as qt_entrega,  
 isnull(pe.qt_entrega,0)                                                        as qt_embalagem,  
 ltrim(rtrim(isnull(cc.nm_fantasia_contato,'')))                                as nm_contato,  
 isnull(pe.cd_contato,0)                                                        as cd_contato,  
 0                                                                              as cd_tipo_proposta,  
 ''                                                                             as nm_tipo_proposta,  
 'N'                                                                            as ic_contrato,  
 0                                                                              as cd_condicao_pagamento,  
 isnull(tpp.cd_tabela_preco,0)                                                  as cd_tabela_preco,  
 isnull(tpp.nm_tabela_preco,'')                                                 as nm_tabela_preco,  
 isnull(pe.ds_entrega,'')                                                       as ds_entrega,  
 isnull(pe.ds_entrega,'')                                                       as ds_observacao_pedido,  
 ''                                                                             as ds_obs_fat_pedido,  
    pe.cd_cliente                                                               as cd_cliente,  
 null                                                                           as ic_fechar_interno,  
 (select top 1 cd_empresa from cliente_empresa where cd_cliente = c.cd_cliente) as cd_empresa,  
 isnull(ef.nm_fantasia_empresa,'')                                              as nm_empresa,  
 ''                                                                             as cd_pedido_compra_consulta,  
 'N'                                                                            as ic_botao_fechamento,  
 isnull(pe.hr_entrega,'')                                                       as hr_entrega,  
 isnull(pe.hr_entrega,'')                                                       as hr_pedido_venda,  
 0                                                                              as cd_consulta_aprovacao,  
 0                                                                              as cd_motivo_aprovacao,  
 ''                                                                             as nm_motivo_aprovacao,  
 null                                                                           as itemCancelado,  
 'N'                                                                            as ic_item_sem_estoque,  
 1                                                                              as cd_tipo_pedido,  
 0                                                                              as cd_relatorio,  
-- @cd_menu                                                                       as cd_menu,  
 'Total R$ '+ dbo.fn_formata_valor(isnull(pe.vl_total_entrega,0))               as nm_valor_total,  
 c.nm_fantasia_cliente                                                          as nm_fantasia_cliente,  
 v.nm_fantasia_vendedor                                                         as nm_fantasia_vendedor,  
 convert(varchar,pe.dt_pedido_entrega,103) + ' - ' + isnull(pe.hr_entrega,'') +   
 isnull(v.nm_fantasia_vendedor,'')                                              as data_consulta,  
 ''                                                                             as rota,  
 c.nm_razao_social_cliente                                                      as nm_razao_social_cliente,
 cc.cd_telefone_contato                                                          as cd_telefone_contato, 
 case when c.cd_tipo_pessoa = 1  
   then ISNULL(  
           SUBSTRING(c.cd_cnpj_cliente, 1, 2) + '.' +  
           SUBSTRING(c.cd_cnpj_cliente, 3, 3) + '.' +  
           SUBSTRING(c.cd_cnpj_cliente, 6, 3) + '/' +  
           SUBSTRING(c.cd_cnpj_cliente, 9, 4) + '-' +  
           SUBSTRING(c.cd_cnpj_cliente, 13, 2)  
       , '')   
   else ISNULL(  
     SUBSTRING(c.cd_cnpj_cliente, 1, 3) + '.' +  
     SUBSTRING(c.cd_cnpj_cliente, 4, 3) + '.' +  
     SUBSTRING(c.cd_cnpj_cliente, 7, 3) + '-' +  
     SUBSTRING(c.cd_cnpj_cliente, 10, 2)  
    , '')  
    end                                                                            as cd_cnpj_cliente,  
 c.cd_tipo_pessoa                                                               as cd_tipo_pessoa,  
 0                                                                              as cd_motivo_troca,  
 ''                                                                             as nm_motivo_troca,  
    isnull(cic.vl_saldo_credito_cliente,0)             as Limite_Credito,  
    'R$ ' + dbo.fn_formata_valor(isnull(cic.vl_saldo_credito_cliente,0))     as Limite_Credito_Formatado,  
 'N'                                                                            as ic_pedido_visita,  
 c.qt_latitude_cliente,  
    c.qt_longitude_cliente,  
 null                                                                           as qt_latitude,  
 null                                                                           as qt_longitude,  
 'N'                                                                            as ic_visita_atendida,  
 'N'                                                                            as ic_item_cancelado,  
 0                                                                              as cd_docuemento,  
    pe.cd_tipo_endereco,  
    pe.cd_servico,  
    pe.vl_servico,  
    pe.qt_saldo_entrega,  
    pe.dt_entrega,  
    pe.qt_distancia_entrega AS qt_distancia_entrega,  
    pe.cd_base,  
    pe.nm_obs_entrega as nm_obs_entrega,  
    pe.cd_status_entrega,  
    pe.ic_cortesia,  
    pe.cd_cep_entrega,  
    pe.cd_identifica_cep,  
    pe.nm_endereco as nm_endereco,  
    pe.cd_numero as cd_numero,  
    pe.nm_complemento as nm_complemento,  
    pe.nm_bairro as nm_bairro,  
    pe.cd_pais as cd_pais,   
    pe.hr_pedido as hr_pedido,  
    pe.dt_cancelamento as dt_cancelamento,  
    pe.nm_motivo_cancelamento as nm_motivo_cancelamento,  
    pe.cd_motorista, 
	mo.nm_motorista as nm_motorista,
    pe.cd_veiculo,  
	se.nm_status_entrega as nm_status_entrega,
	ve.nm_veiculo as nm_veiculo,
    pe.cd_romaneio as cd_romaneio,  
    pe.cd_empresa_faturamento,  
    pe.ic_tipo_faturamento,  
    pe.ic_fracionado,  
    pe.cd_pedido_entrega_origem,  
    pe.cd_cliente_faturar,
	cp.nm_condicao_pagamento as nm_condicao_pagamento,
	est.sg_estado as sg_estado,
	cid.nm_cidade as nm_cidade,
	it.nm_itinerario as nm_itinerario,
	e.nm_entregador as nm_entregador

  
 into 
  #PedidoEntregaEgismobRelatorioCapa  
  from pedido_entrega                         pe   
  left outer join Cliente                     c    on c.cd_cliente  = pe.cd_cliente  
  left outer join Cliente_contato             cc   on cc.cd_cliente = c.cd_cliente   
                                                   and cc.cd_contato = pe.cd_contato  
  left outer join Tabela_Preco                tpp  on tpp.cd_tabela_preco  = c.cd_tabela_preco    
  left outer join Empresa_Faturamento         ef   on ef.cd_empresa   = (select top 1 cd_empresa from cliente_empresa where cd_cliente = c.cd_cliente)   
  left outer join Vendedor                    v    on v.cd_vendedor   = pe.cd_vendedor  
  left outer join status_entrega              se   on se.cd_status_entrega = pe.cd_status_entrega
  left outer join Cliente_Informacao_Credito  cic  on cic.cd_cliente  = c.cd_cliente  
  left outer join pedido_venda                pv   on pv.cd_pedido_venda = pe.cd_pedido_venda
  left outer join Romaneio                    rm   on rm.cd_romaneio           = pe.cd_pedido_entrega
  left outer join Roteiro_Entrega_Composicao  rc   on rc.cd_romaneio           = rm.cd_romaneio
  left outer join Roteiro_Entrega             re   on re.cd_roteiro            = rc.cd_roteiro
  left outer join condicao_pagamento          cp   on cp.cd_condicao_pagamento = pv.cd_condicao_pagamento
  left outer join motorista                   mo   on mo.cd_motorista         = pe.cd_motorista
  LEFT outer join veiculo                     ve   on ve.cd_veiculo           = rm.cd_veiculo
  left outer join Itinerario                  it   on it.cd_itinerario        = re.cd_itinerario
  left outer join Entregador                  e    on e.cd_entregador         = rm.cd_entregador
  left outer join Pais pa with(nolock)             on pa.cd_pais              = c.cd_pais
  left outer join Estado est with(nolock)          on est.cd_pais             = pa.cd_pais	
                                                     and est.cd_estado        = c.cd_estado
  left outer join cidade cid with(nolock)          on cid.cd_pais             = pa.cd_pais    
													and cid.cd_estado         = est.cd_estado
													and cid.cd_cidade         = c.cd_cidade 
  where  
   pe.cd_pedido_entrega = @cd_documento
    -- and  
  --  select * from  pedido_entrega
  --select * from #PedidoEntregaEgismobRelatorioCapa
--------------------------------------------------------------------------------------------------------------	  
select   
 identity(int,1,1)                                    as cd_controle,  
 pe.cd_pedido_entrega                                 as cd_consulta,  
 pe.cd_pedido_entrega                                 as cd_pedido_venda,  
    1                                                 as cd_item_consulta,  
 isnull(convert(varchar,pe.dt_pedido_entrega,103),'') as dt_item_consulta,  
 ''                                                   as Item,  
 0                                                    as cd_grupo_produto,  
 s.nm_servico                                         as Descricao,  
 pe.qt_entrega                                        as qt_item_consulta,        
 pe.qt_entrega                                        as Quantidade,        
 pe.qt_entrega                                        as qtItem,    
 'R$' + dbo.fn_formata_valor(isnull(pe.vl_servico,0)) as Preco_Apresentacao,  
 'R$' + dbo.fn_formata_valor(isnull(pe.vl_servico,0)) as PrecoUnitarioTabela,  
 'R$' + dbo.fn_formata_valor(isnull(pe.vl_servico,0)) as Preco,  
 1                                                    as qt_multiplo_embalagem,  
 'R$' + dbo.fn_formata_valor(isnull(pe.vl_servico,0)) as Unitario,  
 0                                                    as cd_categoria_produto,  
 s.nm_servico                                         as nm_produto,  
 s.nm_servico                                         as Produto,  
 s.cd_servico                                         as cd_produto,  
 s.cd_servico                                         as cd_servico,  
 0                                                    as pc_desconto_item_consulta,  
 pe.vl_servico                                        as vl_total,  
 um.sg_unidade_medida                                  as sg_unidade_medida,  
 pe.vl_servico                                        as vl_total_consulta,  
 0                                                    as vl_icms_st,  
 0                                                    as vl_frete_consulta,  
 0                                                    as vl_total_ipi,  
 0                                                    as ICMS,  
 0    as Ipi,  
 0                                                    as Frete,  
 pe.vl_servico                                        as vl_unitario_item_consulta,  
 pe.vl_servico                                        as vl_total_pedido_venda,  
 pe.vl_servico                                        as vl_unitario_item_consulta2,  
 0                                                    as vl_ipi,  
 0                                                    as vl_item_icms_st,  
 0                                                    as vl_frete_item_pedido,  
 pe.vl_servico                                        as vl_total_item_pedido,  
 ''                                                   as cd_identificacao_nota_saida,  
 10000                                                as Estoque,  
 0                                                    as Fase,  
 ''                                                   as nm_cor_empresa,  
 ''                                                   as nm_logo_empresa,  
 ''                                                   as cd_codigo_barra_produto,  
 0                                                    as cd_motivo_troca,  
 s.sg_servico										  as sg_servico,
 ''                                                   as nm_motivo_troca,  
 10000                                                as Disponivel,  
 10000                                                as Saldo,  
 ''                                                   as ic_sem_estoque,  
 um.nm_unidade_medida                                 as nm_unidade_medida,  
 um.nm_unidade_medida                                 as UN,  
 0                                                    as qt_peso_bruto,  
 0                                                    as totalItems,  
 'Pedido'                                             as estagio,  
 pe.cd_pedido_entrega,  
    pe.dt_pedido_entrega,  
    pe.cd_identificacao,  
    pe.cd_cliente,  
	pe.qt_distancia_entrega AS qt_distancia_entrega,
    pe.cd_contato,  
    pe.cd_tipo_endereco,  
    pe.vl_servico,  
    pe.qt_entrega,  
    pe.qt_saldo_entrega as qt_saldo_entrega,  
    pe.vl_total_entrega as vl_total_entrega,  
    pe.dt_entrega,  
    pe.hr_entrega,  
    pe.cd_base,  
    pe.nm_obs_entrega as nm_obs_entrega,  
    pe.cd_status_entrega,  
    pe.ic_cortesia,  
    pe.ds_entrega,  
    pe.cd_cep_entrega,  
    pe.cd_identifica_cep,  
    pe.nm_endereco,  
    pe.cd_numero as cd_numero,  
    pe.nm_complemento,  
    pe.nm_bairro,  
    pe.cd_pais,  
    pe.cd_estado,  
    pe.cd_cidade,  
    pe.hr_pedido,  
    pe.cd_vendedor,  
    pe.dt_cancelamento,  
    pe.nm_motivo_cancelamento,  
    pe.cd_motorista,  
    pe.cd_veiculo,   
    pe.cd_empresa_faturamento,  
    pe.ic_tipo_faturamento,  
    pe.ic_fracionado,  
    pe.cd_pedido_entrega_origem,  
    pe.cd_cliente_faturar,
	pe.cd_romaneio as cd_romaneio
  
 into #ConsultaItemsEgismobRelatorio  
 from pedido_entrega  pe  
  left outer join Servico         s with(nolock) on s.cd_servico = pe.cd_servico  
  left outer join Unidade_medida um with(nolock) on um.cd_unidade_medida = s.cd_unidade_servico 
  where   
   pe.cd_pedido_entrega = @cd_documento
	-- and  
	--isnull(pe.vl_servico,0) > 0 
--	select * from #ConsultaItemsEgismobRelatorio


--------------------------------------------------------------------------------------------------------------


select 
	@cd_pedido_entrega       = cd_pedido_entrega,
	@dt_pedido_entrega       = dt_pedido_entrega,
	@hr_entrega              = hr_entrega,
	@nm_tabela_preco         = nm_tabela_preco,
	@nm_motivo_cancelamento  = nm_motivo_cancelamento,
	@nm_empresa              = nm_empresa,
	@nm_condicao_pagamento   = nm_condicao_pagamento,	
	@nm_fantasia_cliente     = nm_fantasia_cliente,
	@cd_cnpj_cliente         = cd_cnpj_cliente,
	@nm_fantasia_vendedor    = nm_fantasia_vendedor,
	@nm_razao_social_cliente = nm_razao_social_cliente, 
	@cd_cliente              = cd_cliente,
	@nm_endereco_cliente     = nm_endereco,
	@cd_numero               = cd_numero,
	@nm_bairro				 = nm_bairro,
	@nm_complemento          = nm_complemento,
	@nm_cidade_cliente       = nm_cidade,
	@sg_estado_cliente	     = sg_estado,
	@cd_numero_cliente		 = cd_telefone_contato,
	@nm_contato              = nm_contato,	
	@vl_total_entrega		 = vl_total_entrega,
	@ds_entrega				 = ds_entrega,
	@nm_motorista            = nm_motorista,
	@nm_veiculo              = nm_veiculo,
	@nm_status_entrega       = nm_status_entrega,
	@nm_obs_entrega          = nm_obs_entrega,
	@nm_itinerario           = nm_itinerario,
	@nm_entregador           = nm_entregador,
	@qt_distancia_entrega    = case when isnull(qt_distancia_entrega,0) > 0 then qt_distancia_entrega else '' end,
	@cd_romaneio             = cd_romaneio,
	@dt_cancelamento         = dt_cancelamento

from #PedidoEntregaEgismobRelatorioCapa
declare @qt_entrega_total float = 0
declare @qt_saldo_entrega_total float = 0
select 
	@qt_entrega_total       = sum(qt_entrega),
	@qt_saldo_entrega_total = sum(qt_saldo_entrega)
from 
#ConsultaItemsEgismobRelatorio

if @qt_distancia_entrega = '0'
begin
	set @qt_distancia_entrega = ''
end

--------------------------------------------------------------------------------------------------------------

set @html_geral = '<div class="proposal-info">
        <h2 class="title" style="text-align:center">Pedido de Entrega '+cast(isnull(@cd_pedido_entrega,0) as varchar(20))+'</h2>
        <div
            style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">
            <div style="width:50%">
                <p><strong>Data: </strong>'+isnull(dbo.fn_data_string(@dt_pedido_entrega),'')+' '+ISNULL(@hr_entrega,'')+'<p>
'+ case when isnull(@nm_tabela_preco,'') = '' then '' else '<p><strong>Tabela de Preço: </strong>'+isnull(@nm_tabela_preco,'')+' </p>' end+'
'+ case when isnull(@nm_fantasia_vendedor,'') = '' then '' else '<p><strong>Vendedor: </strong>'+isnull(@nm_fantasia_vendedor,'')+' </p>' end+'		
'+ case when isnull(@cd_romaneio,'') = '' then '' else '<p><strong>Romaneio: </strong>'+cast(isnull(@cd_romaneio,'')as nvarchar(20))+' </p>' end+'	
            </div>
            <div style="width:50%;">
'+ case when isnull(@nm_status_entrega,'') = '' then '' else '<p><strong>Status: </strong>'+isnull(@nm_status_entrega,'')+' </p>' end+' 
'+case when isnull(@nm_motivo_cancelamento,'') = '' then '' else'<p style="color: red;"><strong>Motivo Cancelamento: </strong> '+isnull(@nm_motivo_cancelamento,'')+'</p>' end +'
'+case when isnull(@dt_cancelamento,'') = '' then '' else'<p style="color: red;"><strong>Data Cancelamento: </strong> '+isnull(dbo.fn_data_string(@dt_cancelamento),'')+'</p>' end +'
'+ case when isnull(@nm_empresa,'') = '' then '' else '<p><strong>Empresa de Faturamento: </strong>'+isnull(@nm_empresa,'')+' </p>' end+'  
'+ case when isnull(@nm_condicao_pagamento,'') = '' then '' else '<p><strong>Condição de Pagamento: </strong>'+isnull(@nm_condicao_pagamento,'')+' </p>' end+' 
            </div>
        </div>
    </div>
    <div class="section-title"><strong>Cliente</strong></div>
    <div
        style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">
        <p><strong>Fantasia: </strong>'+ISNULL(@nm_fantasia_cliente,'')+'</p>
        <p><strong>CNPJ:</strong>'+ISNULL(@cd_cnpj_cliente,'')+'</p>
    </div>
    <div
        style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">
        <p><strong>Razão Social: </strong>'+ISNULL(@nm_razao_social_cliente,'')+'</p>
        <p><strong>Cód. do Cliente: </strong>'+CAST(isnull(@cd_cliente,0)as varchar(20))+'</p>
    </div>
    <p><strong>Endereço: </strong>'+ISNULL(@nm_endereco_cliente,'')+' 
	'+case when ISNULL(@cd_numero,'') = '' then '' else ' - Nº ' + ISNULL(@cd_numero,'') end +'
	'+case when ISNULL(@nm_bairro,'') = '' then '' else ' - ' + ISNULL(@nm_bairro,'') end +'
	'+case when ISNULL(@nm_complemento,'') = '' then '' else ' - ' + ISNULL(@nm_complemento,'') end +'
	'+case when ISNULL(@nm_cidade_cliente,'') = '' then '' else ' - ' + ISNULL(@nm_cidade_cliente,'') end +'
	'+case when ISNULL(@sg_estado,'') = '' then '' else ' / ' + ISNULL(@sg_estado_cliente,'') end +'
	</p>
    <p><strong>Telefone: </strong>'+isnull(@cd_numero_cliente,'')+' <strong> - Contato: </strong>'+isnull(@nm_contato,'')+'</p>
	</div>

	<div class="section-title"><strong>Entrega</strong></div>
    <div
        style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">
'+ case when ISNULL(@nm_motorista,'') = '' then '' else '<p><strong>Motorista: </strong>'+ISNULL(@nm_motorista,'')+'</p>' end+' 
'+ case when isnull(@nm_veiculo,'') = '' then '' else '<p><strong>Veiculo: </strong>'+isnull(@nm_veiculo,'')+'</p>' end+' 
        
    </div>
    <div
        style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">
'+ case when isnull(@nm_itinerario,'') = '' then '' else '<p><strong>Rota: </strong>'+isnull(@nm_itinerario,'')+'</p>' end+' 
'+ case when isnull(@nm_entregador,'') = '' then '' else '<p><strong>Entregador: </strong>'+isnull(@nm_entregador,'')+'</p>' end+'
'+ case when isnull(@qt_distancia_entrega,'') = '' then '' else '<p><strong>Distância: </strong>'+isnull(@qt_distancia_entrega,'')+'</p>' end+'
    </div>
   </div>
    <div class="section-title"><strong>Serviços do Pedido</strong></div>
    <table>
        <tr>
            <th style="font-size:12px; width:10%;">Código</th>
            <th style="font-size:12px; width:50%;">Serviço</th>
			<th style="font-size:12px; width:15%">Unidade Medida</th>
			<th style="font-size:12px; width:5%;">Quantidade</th>
            <th style="font-size:12px; width:5%;">Valor($)</th>
        </tr>'
					   
--------------------------------------------------------------------------------------------------------------
WHILE exists (select top 1 cd_controle from #ConsultaItemsEgismobRelatorio)
  begin
  select top 1 
	 @id         = cd_controle,
	 @html_geral = @html_geral+ 
        '<tr class="tamanho">
		    <td>' + CAST(ISNULL(cd_servico, 0) AS NVARCHAR(10)) + '</td>
            <td style="text-align: left">' + ISNULL(nm_produto, '') + '</td>
			<td>'+case when isnull(nm_unidade_medida,'') = '' then isnull(sg_unidade_medida,'') else isnull(nm_unidade_medida,'') end+' </td>
			<td>' + CAST(ISNULL(qt_entrega, 0) AS NVARCHAR(10)) + '</td>
            <td>' + CAST(ISNULL(dbo.fn_formata_valor(vl_total_consulta), 0) AS NVARCHAR(10)) + '</td> 	 
        </tr>'
	from #ConsultaItemsEgismobRelatorio
  DELETE FROM #ConsultaItemsEgismobRelatorio WHERE cd_controle = @id  
END  
--------------------------------------------------------------------------------------------------------------------




set @html_rodape =
    ' </table>
    <div
        style="display: flex; justify-content:right; align-items:start; margin-bottom: 0px; padding-bottom: 0px;width:100%;">
        <div class="company-info" style="justify-content:right; align-items:right">
            <p><strong>Total do Pedido: </strong>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_entrega), 0) as nvarchar(20))+'</p>
        </div>
    </div>
    <div class="section-title"><strong>Observações do Pedido</strong></div>
    '+case when isnull(@ds_entrega,'') = '' then '' else'<p><strong>Descrição Entrega: </strong> '+isnull(@ds_entrega,'')+'</p>' end +'
	'+case when isnull(@nm_obs_entrega,'') = '' then '' else'<p><strong>Observação: </strong> '+isnull(@nm_obs_entrega,'')+'</p>' end +'
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

select 'Pedido de Entrega_'+CAST(isnull(@cd_documento,'')as varchar)+'' AS pdfName,isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------
go

--exec pr_egis_relatorio_pedido_entregue 324,''
------------------------------------------------------------------------------
--exec pr_modulo_processo_egismob_post '[ {"cd_consulta": 34796, "cd_menu": 7667, "cd_parametro": 14, "cd_pedido_venda": 34796, "cd_usuario": 4745}]'
----------------------------------------------------------------------------

