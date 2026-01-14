-------------------------------------------------------------------------------          
--sp_helptext pr_egismob_relatorio_pedido_regis          
-------------------------------------------------------------------------------          
--GBS Global Business Solution Ltda                                        2023          
-------------------------------------------------------------------------------          
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016          
--Autor(es)        : Kelvin Viana        
--Banco de Dados   : EgisAdmin          
--Objetivo         : Gera relatório para tela de pedido de venda do Egismob para cisneros.    
--Data             : 06.01.2025          
--API              : 897/1377
--use egissql_363
---------------------------------------------------------------------------------------------
create or alter procedure pr_egismob_relatorio_pedido_regis       
@json nvarchar(max) = ''       
      
as     
      
declare @cd_parametro          int = 0        
declare @cd_menu               int = 0    
declare @cd_usuario            int = 0
declare @cd_consulta           int = 0
declare @cd_pedido_venda       int = 0,
		@qt_casa_decimal       int = 0
  
----------------------------------------------------------------------------------------------------------    
--Ajuste de Aspas no item da proposta (caso venha com Aspas no nome do produto) 
set @json = replace(@json,'''','')

select                 
identity(int,1,1)             as id,                 
    valores.[key]             as campo,                 
    valores.[value]           as valor                
into #json                
from                 
   openjson(@json)root                
   cross apply openjson(root.value) as valores 	
  ----------------------------------------------------------------------------------------------------------           
   select @cd_parametro              = valor from #json  with(nolock) where campo = 'cd_parametro'     
   select @cd_menu                   = valor from #json  with(nolock) where campo = 'cd_menu'     
   select @cd_usuario                = valor from #json  with(nolock) where campo = 'cd_usuario'     
   select @cd_consulta               = valor from #json  with(nolock) where campo = 'cd_consulta'     
   select @cd_pedido_venda           = valor from #json  with(nolock) where campo = 'cd_pedido_venda'     
   
 
   --empresa_faturamento--

   
	declare @titulo                     varchar(200),
			@logo                       varchar(400),
			@cd_empresa                 int          = 0,
			@nm_cor_empresa             varchar(20),
			@nm_endereco_empresa  	    varchar(200) = '',
			@cd_telefone_empresa    	varchar(200) = '',
			@nm_email_internet		    varchar(200) = '',
			@nm_cidade				    varchar(200) = '',
			@sg_estado				    varchar(10)	 = '',
			@nm_fantasia_empresa	    varchar(200) = '',
			@numero					    int = 0,
			@numeroConsulta				int = 0,
			@dt_pedido				    varchar(60) = '',
			@cd_cep_empresa			    varchar(20) = '',
			@cd_cep						varchar(20) = '',
			@cd_cliente				    int = 0,
			@nm_fantasia_cliente  	    varchar(200) = '',
			@cd_cnpj_cliente		    varchar(30) = '',
			@nm_razao_social_cliente	varchar(200) = '',
			@nm_endereco_cliente		varchar(200) = '',
			@nm_bairro					varchar(200) = '',
			@nm_cidade_cliente			varchar(200) = '',
			@sg_estado_cliente			varchar(5)	= '',
			@nm_complemento_end         varchar(150) = '',
			@cd_numero_endereco			varchar(20) = '',
			@cd_telefone				varchar(20) = '',
			@nm_condicao_pagamento		varchar(100) = '',
			@ds_relatorio				varchar(8000) = '',
			@subtitulo					varchar(40) = '',
			@footerTitle				varchar(200) = '',
			@vl_total_ipi				float = 0,
			@sg_tabela_preco            char(10)     = '',
			@cd_empresa_faturamento     int          = 0,
			@nm_fantasia_faturamento    varchar(30)  = '',
			@cd_tipo_pedido             int          = 0,
			@nm_tipo_pedido             varchar(30)  = '',
			@ic_imposto_tipo_pedido		char(1)		 = 'N',
			@cd_vendedor                int          = 0,
			@nm_fantasia_vendedor       varchar(30)  = '',
			@nm_telefone_vendedor       varchar(30)  = '',
			@nm_email_vendedor          varchar(300) = '',
			@nm_contato_cliente			varchar(200) = '',
			@cd_numero_endereco_empresa varchar(20)	= '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = '',
			@nm_status					varchar(100) = '',
			@ic_empresa_faturamento		char(1) = '',
			@ic_codigo_cliente			char(1) = '',
			@nm_forma_pagamento			varchar(200) = '',
			@nm_semana					varchar(60) = '',
			@nm_itinerario				varchar(40) = '',
			@cd_pdcompra_pedido_venda	varchar(40) = '',
			@ds_obs_fat_pedido			varchar(8000) = '',
			@ic_peso_proposta_pedido    char(1) = 'N',
			@qt_peso_bruto_total        float = 0,
			@pdfName                    varchar(120) = '',
			@nm_item_bonificado         varchar(30)  = '',
			@ic_bonificao               char(1)      = 'N',
			@hr_entrega_cliente         varchar(30) = '',
			@ic_seg_entrega				char(1)      = '',
            @ic_ter_entrega				char(1)      = '',
            @ic_qua_entrega				char(1)      = '',
            @ic_qui_entrega				char(1)      = '',
            @ic_sex_entrega				char(1)      = '',
            @ic_sab_entrega				char(1)      = '',
            @ic_dom_entrega				char(1)      = '',
			@cd_criterio_visita         int = 0,
			@nm_empresa                 varchar(60) = '',
			@qt_bem                     float = 0,
		    @nm_bem                     varchar(100),
		    @dados_bem                  varchar(100)
			


	set @cd_empresa = dbo.fn_empresa()

	--Config_egismob-------------------------------------------------------------
	select 
		@ic_empresa_faturamento = isnull(ic_empresa_faturamento,'N'),
		@ic_codigo_cliente		= isnull(ic_codigo_cliente,'N'),
		@qt_casa_decimal        = isnull(qt_casa_decimal,2),
		@ic_peso_proposta_pedido  = isnull(ic_peso_proposta_pedido,'N')
	from config_egismob
	
	set @qt_casa_decimal = isnull(@qt_casa_decimal,2)
	set @ic_peso_proposta_pedido = isnull(@ic_peso_proposta_pedido,'N')
	
	
	--Dados da empresa-----------------------------------------------------------

	select 
		@logo = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),
		@nm_cor_empresa			= isnull(e.nm_cor_empresa,'#1976D2'),
		@nm_endereco_empresa	= isnull(e.nm_endereco_empresa,''),
		@cd_telefone_empresa	= isnull(e.cd_telefone_empresa,''),
		@nm_email_internet		= isnull(e.nm_email_internet,''),
		@nm_cidade				= isnull(c.nm_cidade,''),
		@sg_estado				= isnull(es.sg_estado,''),
		@nm_fantasia_empresa	= isnull(e.nm_fantasia_empresa,''),
		@nm_empresa				= isnull(e.nm_empresa,''),
		@cd_cep_empresa			= isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),
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

					
	
	--Dados da Proposta/Pedido-----------------------------------------------------------

	if isnull(@cd_pedido_venda,0) > 0 --Pedido
	begin
		
		set @titulo = 'Pedido de Venda'
		set @subtitulo = 'Itens do Pedido'
		set @numero = convert(varchar,isnull(@cd_pedido_venda,0))
		set @footerTitle = 'Total do Pedido:'

		select 
			@dt_pedido = isnull(convert(varchar,pv.dt_pedido_venda,103),''), 
			@cd_cliente = isnull(pv.cd_cliente,0),
			@numeroConsulta			= isnull(pv.cd_consulta,0),
			@nm_condicao_pagamento	= ltrim(rtrim(isnull(cp.nm_condicao_pagamento,''))),
			@ds_relatorio			= cast(isnull(pv.ds_observacao_pedido,'') as varchar(8000)) + '  ' + cast(isnull(ds_pedido_venda,'') as varchar(8000)),
			@sg_tabela_preco        = ISNULL(tp.sg_tabela_preco,''),
			@cd_tipo_pedido         = ISNULL(pv.cd_tipo_pedido,0),
			@cd_empresa_faturamento = ISNULL(pve.cd_empresa,@cd_empresa_faturamento),
			@cd_vendedor            = isnull(pv.cd_vendedor,0),
			@nm_forma_pagamento		= isnull(fp.nm_forma_pagamento,''),
			@nm_contato_cliente		= ltrim(rtrim(isnull(cc.nm_fantasia_contato,''))),
			@cd_pdcompra_pedido_venda = LTRIM(rtrim(isnull(pv.cd_pdcompra_pedido_venda,''))),
			@ds_obs_fat_pedido		= cast(isnull(pv.ds_obs_fat_pedido,'') as varchar(8000)) + '   '+ cast(isnull(ds_pedido_venda_fatura,'') as varchar(8000)),
			@nm_status				= case when pv.cd_pedido_venda <> 0 and pv.cd_status_pedido=1 
										   then 'Pedido'      
										   else case when pv.cd_status_pedido = 2 
													 then 'Faturado'       
												end      
									   end 
										

		from Pedido_venda pv with(nolock)
		     inner join Cliente c                     with(nolock) on c.cd_cliente             = pv.cd_cliente
		     left outer join condicao_pagamento cp    with(nolock) on cp.cd_condicao_pagamento = pv.cd_condicao_pagamento
			 left outer join Tabela_Preco tp          with(nolock) on tp.cd_tabela_preco       = case when isnull(pv.cd_tabela_preco,0)=0 then c.cd_tabela_preco else pv.cd_tabela_preco end
			 left outer join Pedido_Venda_Empresa pve with(nolock) on pve.cd_pedido_venda      = pv.cd_pedido_venda
			 left outer join cliente_contato cc		  with(nolock) on cc.cd_contato			   = pv.cd_contato and cc.cd_cliente = c.cd_cliente
			 left outer join Cliente_informacao_credito cic with(nolock) on cic.cd_cliente	   = c.cd_cliente
			 left outer join Forma_Pagamento fp		  with(nolock) on fp.cd_forma_pagamento	   = cic.cd_forma_pagamento
			 left outer join tipo_pedido	tpe		  with(nolock) on tpe.cd_tipo_pedido	   = pv.cd_tipo_pedido

		where 
			pv.cd_pedido_venda = @cd_pedido_venda

		
		declare @cd_usuario_impressao int
		set @cd_usuario_impressao = case when @cd_usuario in (4458,4479,4574,4580) then @cd_usuario else NULL end

		update Pedido_Venda set cd_usuario_impressao = @cd_usuario_impressao where cd_pedido_venda = @cd_pedido_venda


	end
	else --Proposta
	begin
		set @titulo          = 'Proposta Comercial'
		set @numero          = convert(varchar,isnull(@cd_consulta,0))
		set @numeroConsulta		 = @cd_consulta
		set @subtitulo       = 'Itens da Proposta'
		set @footerTitle     = 'Total da Proposta:'
		set @sg_tabela_preco = ''

		select 
			top 1
			@dt_pedido              = max(isnull(convert(varchar,c.dt_consulta,103),'')), 
			@cd_cliente             = max(isnull(c.cd_cliente,0)),
			@nm_condicao_pagamento  = max(ltrim(rtrim(isnull(cp.nm_condicao_pagamento,'Não informado')))),
			@ds_relatorio			= max(convert(nvarchar(max), isnull(c.ds_observacao_consulta,''))),
			@sg_tabela_preco        = max(ISNULL(tp.sg_tabela_preco,'')),
			@cd_tipo_pedido         = max(ISNULL(tpo.cd_tipo_pedido,0)),
			@cd_empresa_faturamento = max(ISNULL(ce.cd_empresa,@cd_empresa_faturamento)),
			@cd_vendedor            = max(isnull(c.cd_vendedor,0)),
			@nm_contato_cliente		= max(ltrim(rtrim(isnull(cc.nm_fantasia_contato,'')))),
			@nm_forma_pagamento		= max(isnull(fp.nm_forma_pagamento,'')),
			@cd_pdcompra_pedido_venda = isnull(MAX(c.cd_pedido_compra_consulta),''),
			@ds_obs_fat_pedido		  = max(ltrim(rtrim(isnull(cast(c.ds_obs_fat_consulta as varchar),'')))),
			@nm_status				=  max(cast(case when vw.cd_pedido_venda = 0 
													 then 'Aguardando'       
													 else case when vw.dt_entrega_nota_saida is not null 
															   then 'Entregue'      
														  else case when vw.cd_identificacao_nota_saida <> 0
																	then 'Faturado' 
																	else 'Pedido' 
																end      
														  end      
												end							as varchar(15)))                
                                                                                                   

		from Consulta c with(nolock)
		inner join Cliente cli                with(nolock) on cli.cd_cliente           = c.cd_cliente
		left outer join condicao_pagamento cp with(nolock) on cp.cd_condicao_pagamento = c.cd_condicao_pagamento
		left outer join Tabela_Preco tp       with(nolock) on tp.cd_tabela_preco       = case when isnull(c.cd_tabela_preco,0)=0 then cli.cd_tabela_preco else c.cd_tabela_preco end
		left outer join Tipo_Proposta tpo     with(nolock) on tpo.cd_tipo_proposta     = c.cd_tipo_proposta
		left outer join Consulta_Empresa ce   with(nolock) on ce.cd_consulta           = c.cd_consulta
		left outer join cliente_contato cc	  with(nolock) on cc.cd_contato			   = c.cd_contato and cc.cd_cliente = c.cd_cliente
		left outer join Cliente_informacao_credito cic with(nolock) on cic.cd_cliente	= c.cd_cliente
		left outer join vw_proposta_bi vw		with(nolock) on vw.cd_consulta			= c.cd_consulta
		left outer join Forma_Pagamento fp		with(nolock) on fp.cd_forma_pagamento	= cic.cd_forma_pagamento

		where 
			c.cd_consulta = @cd_consulta
		       
	   group by      
	     vw.cd_consulta,      
	     vw.cd_vendedor  
	end
	
	--Dados do Vendedor----------------------------------------------------------
	declare @nm_vendedor varchar(200)
	set @nm_vendedor = (select ltrim(rtrim(isnull(nm_fantasia_vendedor,''))) from vendedor where cd_vendedor = @cd_vendedor)

	--Dados do Cliente-----------------------------------------------------------

	select 
		@nm_fantasia_cliente	    = ltrim(rtrim(isnull(c.nm_fantasia_cliente,''))),
		@cd_cnpj_cliente		    = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(c.cd_cnpj_cliente,'')))),
		@nm_razao_social_cliente	= ltrim(rtrim(isnull(c.nm_razao_social_cliente,''))),
		@nm_endereco_cliente		= ltrim(rtrim(isnull(c.nm_endereco_cliente,''))),
		@nm_bairro					= ltrim(rtrim(isnull(c.nm_bairro,''))),
		@cd_cep                     = ltrim(rtrim(isnull(c.cd_cep,''))),
		@nm_cidade_cliente			= ltrim(rtrim(isnull(cid.nm_cidade,''))),
		@sg_estado_cliente			= ltrim(rtrim(isnull(e.sg_estado,''))),
		@nm_complemento_end         = ltrim(rtrim(isnull(c.nm_complemento_endereco,''))),
		@cd_numero_endereco			= ltrim(rtrim(isnull(c.cd_numero_endereco,''))),
		@cd_telefone		   	    = '('+ltrim(rtrim(isnull(c.cd_ddd,''))) + ')'+ltrim(rtrim(isnull(c.cd_telefone,''))),
		@nm_semana					= ltrim(rtrim(isnull(s.nm_semana,''))),
		@nm_itinerario				= ltrim(rtrim(isnull(i.nm_itinerario,''))),
		@hr_entrega_cliente			= ltrim(rtrim(isnull(cp.hr_entrega_cliente,''))),
		@ic_seg_entrega				= isnull(cp.ic_seg_entrega,''),
		@ic_ter_entrega				= isnull(cp.ic_ter_entrega,''),
		@ic_qua_entrega				= isnull(cp.ic_qua_entrega,''),
		@ic_qui_entrega				= isnull(cp.ic_qui_entrega,''),
		@ic_sex_entrega				= isnull(cp.ic_sex_entrega,''),
		@ic_sab_entrega				= isnull(cp.ic_sab_entrega,''),
		@ic_dom_entrega				= isnull(cp.ic_dom_entrega,''),
		@cd_criterio_visita         = isnull(i.cd_criterio_visita ,'')

	from cliente c with(nolock)
	left outer join estado e		  with(nolock) on e.cd_estado     = c.cd_estado 
	left outer join cidade cid		  with(nolock) on cid.cd_cidade   = c.cd_cidade and cid.cd_estado = c.cd_estado
	left outer join Semana s		  with(nolock) on s.cd_semana     = c.cd_semana
	left outer join Itinerario i	  with(nolock) on i.cd_itinerario = c.cd_itinerario
	left outer join cliente_perfil cp with(nolock) on cp.cd_cliente   = c.cd_cliente
	where 
		c.cd_cliente = @cd_cliente


	--Bem--
	
	select
      @qt_bem    = count(cd_bem),
      @nm_bem    = max(nm_bem),
      @dados_bem = max(nm_bem + ' ' + ltrim(rtrim(cd_patrimonio_bem)) + '  ' + nm_modelo_bem )
    from
      bem b
	where
	  cd_cliente = @cd_cliente
	order by
	  max(b.dt_aquisicao_bem) desc


    --Tipo de Pedido--

	if @cd_tipo_pedido>0
	begin
	  select top 1
	    @nm_tipo_pedido = nm_titulo_tipo_pedido,
		@ic_bonificao   = isnull(ic_bonificacao_tipo_pedido,'N')
	  from
	    Tipo_Pedido
	  where
	    cd_tipo_pedido = @cd_tipo_pedido

	end

	if @ic_bonificao = 'S'
	begin
	  set @nm_item_bonificado = 'ITEM BONIFICADO'
	end
	
    --Empresa Faturamento--
	--select * from empresa_faturamento

    if isnull(@cd_empresa_faturamento,0) > 0
	begin
	  select top 1
	    @nm_fantasia_faturamento = ltrim(rtrim(ISNULL(nm_fantasia_empresa,'')))
	  from
	    Empresa_Faturamento 
	  where
	    cd_empresa = @cd_empresa_faturamento

	end

	--Dados do Vendedor----------------------------------------------------------

	if @cd_vendedor>0
	begin

	  select
	    @nm_fantasia_vendedor  = isnull(nm_fantasia_vendedor,''),
	    @nm_telefone_vendedor  = isnull(cd_telefone_vendedor,''),    
	    @nm_email_vendedor     = isnull(nm_email_vendedor,'')     
      from
	    vendedor
      where
	    cd_vendedor = @cd_vendedor

	end
	   
	--Dados dos Itens------------------------------------------------------------

	if isnull(@cd_pedido_venda,0) > 0
	begin
		set @cd_consulta = 0
	end


	select
	  c.cd_consulta,
	  isnull(c.cd_pedido_venda,0)					as cd_pedido_venda,
	  c.vl_total_consulta,
	  c.cd_item_consulta							as cd_item_consulta,
	  c.dt_pedido_venda,
	  isnull(c.cd_item_consulta,0)					as Item,
	  isnull(c.qt_item_consulta,0)					as Quantidade,
	  c.cd_mascara_produto							as Codigo_Produto,
	  c.nm_fantasia_produto							as Fantasia,
	  c.vl_unitario_item_consulta					as Unitario,
	  c.TotalItem									as Total,
	  c.nm_produto_consulta							as Descricao_Produto,
	  c.sg_unidade_medida							as Unidade,
	  c.qt_volume_produto							as Volume,
	  c.qt_embalagem								as Embalagem,
	  c.cd_consulta									as Numero,
	  c.dt_entrega_consulta							as DataEntrega,
	  isnull(c.cd_pedido_venda,0)					as Pedido,
	  isnull(tp.nm_tipo_pedido,'')					as TipoPedido,
	  isnull(c.cd_consulta,0)											 as Consulta,
	  isnull(c.nm_condicao_pagamento,'')								 as nm_condicao_pagamento,
	  isnull(c.vl_total_ipi,0)											 as vl_total_ipi,
	  dbo.fn_formata_valor(isnull(c.vl_total_ipi,0))					 as vl_total_ipi_unitario,
	  isnull(c.vl_icms_st,0)											 as vl_icms_st,
	  isnull(c.vl_frete_consulta,0)										 as vl_frete_consulta,
	  'R$' + dbo.fn_formata_valor(isnull(c.vl_total_ipi,0))				 as Ipi,
	  'R$' + dbo.fn_formata_valor(isnull(c.vl_icms_st,0))				 as ICMS,
	  'R$' + dbo.fn_formata_valor(isnull(c.vl_frete_consulta,0))		 as Frete,
	  isnull(c.vl_total_ipi,0)								   		 	 as vl_ipi,
	  isnull(c.vl_item_icms_st,0)						   				 as vl_item_icms_st,
	  isnull(c.vl_frete_consulta,0)					   					 as vl_frete_item_pedido,
	  isnull(c.vl_unitario_item_consulta,0)								 as vl_unitario_item_consulta2,	  
	  case when @qt_casa_decimal > 2
	       then dbo.fn_formata_valor_decimal(isnull(c.vl_unitario_item_consulta,0), @qt_casa_decimal)
		   else dbo.fn_formata_valor(isnull(c.vl_unitario_item_consulta,0))
	  end                                                                as vl_unitario_item_consulta,
	  'R$' + dbo.fn_formata_valor(isnull(c.vl_total_consulta,0))		 as vl_total_pedido_venda,
	  c.TotalItemLiquido                                                 as vl_total_item_pedido,
	  isnull(c.pc_ipi,0)					 							as pc_ipi,
	  isnull(c.cd_identificacao_nota_saida,0)							as cd_identificacao_nota_saida,
	  isnull(c.sg_unidade_medida,'')									as sg_unidade_medida,
	  isnull(p.cd_codigo_barra_produto,'')								as cd_codigo_barra_produto,
	  c.cd_produto,
	  c.cd_fase_produto,
	  isnull(c.cd_servico,0)											as cd_servico,
	  isnull(c.nm_produto_consulta,'')									as nm_produto_consulta,
	  isnull(c.nm_fantasia_produto,'')									as nm_fantasia_produto,
	  isnull(c.cd_tipo_pedido,0)										as cd_tipo_pedido

	  --select vl_total_pedido_ipi from vw_proposta_bi
	into #PropostaMob
	from
	  vw_proposta_bi c with(nolock)
	  left outer join Tipo_Pedido tp with(nolock) on tp.cd_tipo_pedido  = c.cd_tipo_pedido
	  left outer join produto		p with(nolock) on p.cd_produto		= c.cd_produto
	where
	  c.cd_consulta = @cd_consulta
	  and 
	  isnull(c.cd_pedido_venda,0)=0
	  and c.dt_perda_consulta_itens is null  
	 
	order by
	  c.cd_item_consulta
		
	
	--Pedido de Venda--------------------------------------------------------------------------------------------------
	
	select 
	  c.cd_pedido_venda													as cd_consulta,
	  isnull(c.cd_pedido_venda,0)										as cd_pedido_venda,
	  c.vl_total_pedido_ipi												as vl_total_pedido_ipi,
	  isnull(pvi.cd_item_consulta,0)									as cd_item_consulta,
	  pvi.dt_item_pedido_venda											as dt_item_consulta,
	  pvi.cd_item_pedido_venda											as Item,
	  pvi.qt_item_pedido_venda											as Quantidade,
	  p.cd_mascara_produto												as Codigo_Produto,
	  pvi.nm_fantasia_produto												as Fantasia,
	  CASE WHEN (pvi.dt_cancelamento_item IS NULL) 
		   THEN (pvi.vl_unitario_item_pedido) 
		   ELSE 0.00
	  END																as Unitario,
	  case when pvi.dt_cancelamento_item is null
		   then pvi.vl_unitario_item_pedido * pvi.qt_item_pedido_venda         
		   else 0.00        
      end			          											as Total,
	  pvi.nm_produto_pedido												as Descricao_Produto,
	  um.sg_unidade_medida  											as Unidade,
	  isnull(p.qt_volume_produto,0) * pvi.qt_item_pedido_venda  		as Volume,
	  round(case when isnull(p.qt_multiplo_embalagem,0) <> 0 
				 then isnull(pvi.qt_item_pedido_venda,0)/p.qt_multiplo_embalagem        
				 else 0.00        
			end,0)														as Embalagem,
	  c.cd_pedido_venda													as Numero,
	  pvi.dt_entrega_vendas_pedido	 									as DataEntrega,
	  c.cd_pedido_venda													as Pedido,
	  isnull(tp.nm_tipo_pedido,'')										as TipoPedido,
	  isnull(pvi.cd_consulta,0)											as Consulta,
	  isnull(cp.nm_condicao_pagamento,'')								as nm_condicao_pagamento,
	  isnull(CASE WHEN (pvi.dt_cancelamento_item IS NULL) 
				  THEN ((((pvi.vl_unitario_item_pedido * pvi.qt_item_pedido_venda) * isnull(pvi.pc_ipi,0) )/100 ))
				  ELSE 0.00 
			 END ,0)				 									as vl_total_ipi,
	  dbo.fn_formata_valor(isnull(CASE WHEN (pvi.dt_cancelamento_item IS NULL) 
									   THEN ((((pvi.vl_unitario_item_pedido * pvi.qt_item_pedido_venda) * isnull(pvi.pc_ipi,0) )/100 )) 
									   ELSE 0.00 
								  END,0))								as vl_total_ipi_unitario,
	  
	   ----

	  isnull(pvi.vl_item_icms_st,0)										as vl_icms_st,
	  isnull(pvi.vl_frete_item_pedido,0)								as vl_frete_consulta,
	  'R$' + dbo.fn_formata_valor(isnull(CASE WHEN (pvi.dt_cancelamento_item IS NULL) 
											  THEN ((((pvi.vl_unitario_item_pedido * pvi.qt_item_pedido_venda) * isnull(pvi.pc_ipi,0) )/100 )) 
											  ELSE 0.00 
										 END,0))		     			as Ipi,
	  'R$' + dbo.fn_formata_valor(isnull(pvi.vl_item_icms_st,0))		as ICMS,
	  'R$' + dbo.fn_formata_valor(isnull(pvi.vl_frete_item_pedido,0))	as Frete,
	  isnull(CASE WHEN (pvi.dt_cancelamento_item IS NULL) 
				  THEN ((((pvi.vl_unitario_item_pedido * pvi.qt_item_pedido_venda) * isnull(pvi.pc_ipi,0) )/100 )) 
				  ELSE 0.00 
			 END,0)										 				as vl_ipi,
	  isnull(pvi.vl_item_icms_st,0)										as vl_item_icms_st,
	  isnull(pvi.vl_frete_item_pedido,0)								as vl_frete_item_pedido,
	  isnull(pvi.vl_unitario_item_pedido ,0)													as vl_unitario_item_consulta2,
	  dbo.fn_formata_valor(isnull(pvi.vl_unitario_item_pedido,0))								as vl_unitario_item_consulta,
	  'R$' + dbo.fn_formata_valor(isnull(case when pvi.dt_cancelamento_item is null 
											  then pvi.vl_unitario_item_pedido * pvi.qt_item_pedido_venda         
											  else 0.00        
										 end,0))						as vl_total_pedido_venda,       
      case when pvi.dt_cancelamento_item is null 
		   then pvi.vl_unitario_item_pedido * pvi.qt_item_pedido_venda         
		   else 0.00        
      end					                                            as vl_total_item_pedido,
	  isnull(pvi.pc_ipi,0)												as pc_ipi,
	  0																	as cd_identificacao_nota_saida,
	  ''																as sg_unidade_medida,
	  isnull(p.cd_codigo_barra_produto,'')								as cd_codigo_barra_produto,
	  isnull(pvi.cd_produto, 0)											as cd_produto,
	  case when isnull(pvi.cd_fase_produto,0) > 0 
		   then pvi.cd_fase_produto  
		   else p.cd_fase_produto_baixa  
	  end																as cd_fase_produto,
	  isnull(pvi.cd_servico,0)											as cd_servico,
  	  isnull(pvi.nm_produto_pedido,'')									as nm_produto_consulta,
	  isnull(pvi.nm_fantasia_produto,'')								as nm_fantasia_produto,
	  isnull(c.cd_tipo_pedido,0)										as cd_tipo_pedido
	into #PedidoMob
	
	  
	from
	  Pedido_Venda c with(nolock)
	  INNER JOIN Pedido_Venda_Item pvi		with (nolock) ON c.cd_pedido_venda       = pvi.cd_pedido_venda  
	  LEFT OUTER JOIN Produto p				with (nolock) ON p.cd_produto             = pvi.cd_produto  
	  LEFT OUTER JOIN Unidade_Medida um		with (nolock) ON um.cd_unidade_medida     = pvi.cd_unidade_medida 
	  left outer join Condicao_Pagamento cp with(nolock) on cp.cd_condicao_pagamento = c.cd_condicao_pagamento
	  left outer join Tipo_Pedido tp		with(nolock) on tp.cd_tipo_pedido        = c.cd_tipo_pedido
	
	where
		c.cd_pedido_venda = @cd_pedido_venda
		and pvi.dt_cancelamento_item is null --convert(varchar(7),isnull(pvi.dt_cancelamento_item, DateAdd(month,1,c.dt_pedido_venda)),121) > convert(varchar(7),c.dt_pedido_venda,121)
		AND isnull(c.ic_consignacao_pedido, 'N') <> 'S'
		AND isnull(pvi.qt_item_pedido_venda * pvi.vl_unitario_item_pedido,0) > 0 
		AND isnull(c.ic_amostra_pedido_venda,'N') <> 'S'              
		AND isnull(c.vl_total_pedido_venda,0) > 0
		AND isnull(pvi.cd_produto_servico,0)   = 0                     
  
	
	order by
	   
	  pvi.cd_item_pedido_venda
	
		
	insert into #PropostaMob
	select * from #PedidoMob
	
	--select * from #PropostaMob

	--if isnull(@cd_pedido_venda,0) > 0
	--begin
	--	select * from #PropostaMob where cd_consulta = @cd_consulta
	--	delete from #PropostaMob where cd_consulta = @cd_consulta
	--end
	--select * from #PropostaMob

	select 
	  identity(int,1,1)                                  as cd_controle,  
	  c.cd_consulta,
	  isnull(c.cd_pedido_venda,0)						 as cd_pedido_venda,
	  Unitario 											 as vl_total_pedido_ipi,
	  c.cd_item_consulta								 as cd_item_consulta,
	  convert(varchar,c.dt_pedido_venda,103)             as dt_item_consulta,
	  isnull(p.cd_grupo_produto,0)                       as cd_grupo_produto,

	  --isnull(p.nm_produto,'')                            as Descricao,
	   case when isnull(p.cd_produto,0) > 0 
			then isnull(p.nm_produto,'')
		else case when isnull(c.cd_servico,0) > 0 
			then isnull(s.nm_servico,'')	
		else c.nm_produto_consulta
			end
	   end														as Descricao,
	  isnull(c.Quantidade,0)									as qt_item_consulta,
	  isnull(c.Quantidade,0)									as Quantidade,
	  isnull(c.Unitario * c.Quantidade,0)                                  as vl_total_linha_liquido,
	  case when @qt_casa_decimal > 2 then 
        dbo.fn_formata_valor_decimal(
            case when isnull(@cd_empresa,0) = 354 
                then isnull(c.Unitario * c.Quantidade,0) + isnull(c.vl_frete_consulta,0)
                else isnull(c.Unitario * c.Quantidade,0)  + isnull(c.vl_item_icms_st,0) + isnull(c.vl_frete_consulta,0) + round(((isnull(c.Unitario,0) * c.Quantidade) + isnull(c.vl_frete_item_pedido,0))  * isnull(c.pc_ipi / 100,0), 2) end, @qt_casa_decimal)

    else 
        dbo.fn_formata_valor(
            case when isnull(@cd_empresa,0) = 354 
                then isnull(c.Unitario * c.Quantidade,0) + isnull(c.vl_frete_consulta,0)
                else isnull(c.Unitario * c.Quantidade,0) + isnull(c.vl_item_icms_st,0) + isnull(c.vl_frete_consulta,0) + round(((isnull(c.Unitario,0) * c.Quantidade) + isnull(c.vl_frete_item_pedido,0)) * isnull(c.pc_ipi / 100,0), 2) end)
        end 		as qtItem,
    case when isnull(@cd_empresa,0) = 354 then 
		isnull(c.Unitario * c.Quantidade,0) 
		else 
		isnull(c.Unitario * c.Quantidade,0) 
		+ 
		isnull(c.vl_item_icms_st,0)
		+
		isnull(c.vl_frete_consulta,0)
		+
		round(((isnull(c.Unitario,0)  * c.Quantidade )  
		 + 
		isnull(c.vl_frete_item_pedido,0)) * isnull(c.pc_ipi / 100,0),2 ) end as  vl_total_linha,
	    'R$'+dbo.fn_formata_valor(isnull(c.Unitario,0))					as Preco,  
	  p.cd_categoria_produto,
	  isnull(p.nm_produto,'')											as nm_produto,
	 
		case when isnull(p.cd_produto,0) > 0 
			then isnull(p.nm_fantasia_produto,'')
			else 
				case when isnull(c.cd_servico,0) > 0 
					then isnull(s.ds_servico,'')	
				else c.nm_fantasia_produto
			end
		end																		 as Produto,
	  c.cd_produto,
	  isnull(c.cd_servico,0)													 as cd_servico,
	  c.vl_total_consulta                                                        as vl_total,
	  isnull(p.cd_unidade_medida,0)                                              as cd_unidade_medida,  
	  isnull(um.nm_unidade_medida,'')                                            as nm_unidade_medida, 
	  'Total: R$'+dbo.fn_formata_valor(isnull(c.vl_total_consulta,0))            as vl_total_consulta,
	  round(c.vl_item_icms_st,2)												 as vl_icms_st,
	  round(c.vl_frete_consulta,2)												 as vl_frete_consulta,
	  ----
	  round(((isnull(c.Unitario,0)  * c.Quantidade )  
	  + 
	  isnull(c.vl_frete_item_pedido,0)) * isnull(c.pc_ipi / 100,0),2 )			 as vl_total_ipi,
	  dbo.fn_formata_valor(
	  round(((isnull(c.Unitario,0)  * c.Quantidade )  
	  + 
	  isnull(c.vl_frete_item_pedido,0)) * isnull(c.pc_ipi / 100,0),2 ))			 as vl_total_ipi_unitario,
	  ----
	  round(((isnull(c.Unitario,0)  * c.Quantidade )  
	  + 
	  isnull(c.vl_frete_item_pedido,0)) * isnull(c.pc_ipi / 100,0),2 )			 as vl_total_ipi_footer,
	  c.ICMS,
	  c.Ipi,
	  c.Frete,
	  c.vl_unitario_item_consulta,
	  c.vl_total_pedido_venda,
	  c.vl_unitario_item_consulta2,
	  c.vl_ipi,
	  dbo.fn_formata_valor(isnull(c.vl_item_icms_st,0))							as vl_item_icms_st,
	  c.vl_frete_item_pedido,
	  c.vl_total_item_pedido,
	  c.cd_identificacao_nota_saida,
	  --c.*,
	  ps.qt_saldo_atual_produto    as Estoque,
	  fp.nm_fase_produto           as Fase,
	  isnull(@nm_cor_empresa,'')										as nm_cor_empresa,  
	  isnull(p.cd_codigo_barra_produto,'')								as cd_codigo_barra_produto,
	  isnull(cpt.cd_motivo_troca,0)										as cd_motivo_troca,
	  isnull(mt.nm_motivo_troca,'')										as nm_motivo_troca,
	  isnull(cf.cd_mascara_classificacao,'')							as NCM,
	  isnull(c.cd_tipo_pedido,0)										as cd_tipo_pedido,
	  isnull(p.qt_peso_bruto,0)                                         as qt_peso_bruto

	  
	  --select * from mob_tipo_pedido

	into #ApresentacaoItens
	from
	  #PropostaMob c with(nolock)
	  left outer join Produto p				with(nolock) on p.cd_produto			= c.cd_produto
	  left outer join Produto_Saldo ps		with(nolock) on ps.cd_produto			= c.cd_produto and
															ps.cd_fase_produto		= c.cd_fase_produto
	  left outer join Fase_Produto  fp		with(nolock) on fp.cd_fase_produto		= c.cd_fase_produto
	  left outer join Consulta_Pedido_Troca cpt	with(nolock) on cpt.cd_consulta		= c.cd_consulta
	  left outer join Motivo_Troca          mt 	with(nolock) on mt.cd_motivo_troca	= cpt.cd_motivo_troca
	  left outer join Servico				s	with(nolock) on s.cd_servico		= c.cd_servico
	  left outer join Mob_Tipo_Pedido		mtp	with(nolock) on mtp.cd_tipo_pedido	= c.cd_tipo_pedido
	  left outer join Unidade_Medida um			with(nolock) on um.cd_unidade_medida		= case when isnull(mtp.ic_utiliza_unidade_medida,'N') = 'S'	and isnull(mtp.cd_unidade_medida,0) > 0
																								then isnull(mtp.cd_unidade_medida,0)
																								else isnull(p.cd_unidade_medida,s.cd_unidade_medida)
																								end
	  left outer join Produto_Fiscal pf			with(nolock) on pf.cd_produto				= p.cd_produto
	  left outer join Classificacao_Fiscal cf	with(nolock) on cf.cd_classificacao_fiscal	= pf.cd_classificacao_fiscal

	order by
	  c.item
	  
	  
declare @html nvarchar(max),
        @data_hora_atual nvarchar(50),
		@vl_total_pedido_venda float = 0
select 
	@vl_total_pedido_venda	= sum(vl_total_linha),
	@qt_peso_bruto_total     = sum(qt_peso_bruto * Quantidade)--,
	--@vl_total_ipi			= 'R$ ' + dbo.fn_formata_valor(cast(isnull(vl_total_ipi_footer,0) as varchar))
	from #ApresentacaoItens
	
	
-- Obtém a data e hora atual
SET @data_hora_atual = CONVERT(nvarchar, GETDATE(), 103) + ' ' + LEFT(CONVERT(nvarchar, GETDATE(), 108), 5)

SET @html = '
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title >'+case when isnull(@cd_consulta,0) > 0 then 'Proposta' else isnull(@nm_tipo_pedido,'') end +'</title>
      <style>
    body {
      font-family: Arial, sans-serif;
      color: #333;
      padding: 1px
    }

    h2 {
      color: #333;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 2px;
      margin-right: 1px;
    }

    table,
    th,
    td {
      border: 1px solid #ddd;
    }

    th,
    td {
      padding: 1px;
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
      padding: 1px;
      text-align: center;
    }

    .section-title {
      background-color: #1976D2;
      color: white;
      padding: 5px;
      margin-bottom: 1px;
      border-radius: 5px;
      font-size: 14px;
    }

    img {
      max-width: 120px;
      max-height: 120px;
   
    }

    .company-info {
      text-align: right;
      margin-bottom: 1px;
    }

    .proposal-info {
      text-align: left;
      margin-bottom: 1px;
    }

    .title {
      color: #1976D2;
      font-size: 14px;
    }

    .report-date-time {
      text-align: right;
      margin-bottom: 5px;
      margin-top: 10px;
    }

    p {
      margin: 1px;
      padding: 0;
      font-size: 12px
    }

  @media print {
  @page {
    size: auto;    
    margin: 0mm;
 }

  body {
    margin: 10px;
    padding: 0;
  }
 }
</style>
</head>
<body>
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:20%; margin-right:10px">
			<img src="'+isnull(@logo,'')+'" alt="Logo da Empresa">
		</div>
		<div style="width:60%; padding-left:5px">
			<p>
			 <span class="title">'+ISNULL(@nm_fantasia_empresa,'')+' - </span>
			 <span style="font-weight: bold;font-size: 14px;">'+ISNULL(@nm_empresa,'')+'</span>
			</p>
		    <p><strong>'+isnull(@nm_endereco_empresa,'')+', '+isnull(@cd_numero_endereco_empresa,'') + ' - '+isnull(@cd_cep_empresa,'')+ ' - '+isnull(@nm_cidade,'')+' - '+isnull(@sg_estado,'')+' - ' + isnull(@nm_pais,'') + '</strong></p>
		    <p><strong>Fone: </strong>'+isnull(@cd_telefone_empresa,'')+' - <strong>CNPJ: </strong>' + isnull(@cd_cnpj_empresa,'') + ' - <strong>I.E: </strong>' + isnull(@cd_inscestadual_empresa,'') + '</p>
		    <p>'+isnull(@nm_dominio_internet,'')+ ' - ' + isnull(@nm_email_internet,'')+'</p>
		</div>
		<div style="width:20%;">
		<h2 class="title" style="text-align:center">'+case when isnull(@cd_consulta,0) > 0 then 'Proposta' else isnull(@nm_tipo_pedido,'') end +' '+isnull(convert(varchar,@numero),'')+'</h2>
		 <p style="text-align:center">Gerado: '+isnull(@data_hora_atual,'')+'</p>
		</div>
        </div> 
    <div>
	 <div style="display: flex;flex-wrap: wrap; gap: 10px 30px; line-height: 1.5;text-align: justify;max-width: 100%;">
			'+case when isnull(@dt_pedido,'') <> '' then '<p style="margin: 0;"><strong>Data: </strong>'+isnull(@dt_pedido,'')+'</p>' else ''end + ' 
			'+case when isnull(@nm_tipo_pedido,'') <> '' then '<p style="margin: 0;"><strong>Tipo de Pedido: </strong>'+isnull(@nm_tipo_pedido,'')+'</p>' else ''end + '
			'+case when isnull(@sg_tabela_preco,'') <> '' then '<p style="margin: 0;"><strong>Tabela de Preço: </strong>'+isnull(@sg_tabela_preco,'')+'</p>' else ''end + '
			'+case when isnull(@nm_vendedor,'') <> '' then '<p style="margin: 0;"><strong>Vendedor: </strong>'+isnull(@nm_vendedor,'')+'' else '</p>'end + '
	</div>
	 <div style="display: flex;flex-wrap: wrap; gap: 10px 30px; line-height: 1.5;text-align: justify;max-width: 100%;">
			'+case when isnull(@cd_pdcompra_pedido_venda,'') <> '' then '<p style="margin: 0;"><strong>Pedido de Compra: </strong>'+isnull(@cd_pdcompra_pedido_venda,'')+'' else ''end+'</p>
			'+case when isnull(@nm_status, '') <> '' then '<p style="margin: 0;"><strong>Status: </strong>' + ltrim(rtrim(isnull(@nm_status, '')))+'' else ''end+'</p>
			'+case when isnull(@nm_fantasia_faturamento,'') <> '' then '<p style="margin: 0;"><strong>Empresa de Faturamento: </strong>' + isnull(@nm_fantasia_faturamento,'') + '</p>' else ''end + '
			'+case when isnull(@nm_condicao_pagamento,'') <> '' then '<p style="margin: 0;"><strong>Condição de Pagamento: </strong>' + isnull(@nm_condicao_pagamento,'') + '' else ''end + '</p>
			<p style="margin: 0;"><strong>Proposta Comercial: </strong>' + isnull(cast(@numeroConsulta as varchar),'') + '</p>
			</div>
		</div>	  
		<hr style="border: 1px solid black; margin: 8px 0;">
  <div style="display: flex;justify-content: space-between;font-size: 14px;margin-top: 2px;"> 
		<p><strong>Cliente:</strong> '+case when isnull(@nm_fantasia_cliente,'') <> '' then ''+isnull(@nm_fantasia_cliente,'')+'' else ''end + ' 
		                         '+case when @ic_codigo_cliente = 'S'then '('+isnull(cast(@cd_cliente as varchar),'')+')'else '' end + '</p> 
		<p>'+case when isnull(@cd_empresa,0) <> 329 then '<strong>Telefone: </strong>'+isnull(@cd_telefone,'')+'' else '' end +'</p> 
	</div>
'
		  
SET @html = @html +
'	<div style="display: flex;justify-content: space-between;"> 
	    <p><strong>Razão Social: </strong>'+isnull(@nm_razao_social_cliente,'')+' </p>
		<p><strong>CNPJ:</strong> '+isnull(@cd_cnpj_cliente,'')+' </p>
		</div>
 <p> <strong>Endereço: </strong>
	'+case when isnull(@nm_endereco_cliente,'') <> '' then isnull(@nm_endereco_cliente,'') else '' end +' '+isnull(@nm_endereco_cliente,'')+' 
	'+case when isnull(@cd_numero_endereco,'') <> '' then  '- N° '+isnull(@cd_numero_endereco,'')+'' else '' end +' 
	'+case when isnull(@nm_complemento_end,'') = '' then '' else ' - '+@nm_complemento_end+''  end +' 
	'+case when isnull(@nm_bairro,'') <> '' then  ' - '+isnull(@nm_bairro,'')+'' else '' end +' 
	'+case when isnull(@cd_cep,'') <> '' then  ' - '+isnull(@cd_cep,'')+'' else '' end +' 
	'+case when isnull(@nm_cidade_cliente,'') <> '' then  ' - '+isnull(@nm_cidade_cliente,'')+'' else '' end +' 
	'+case when isnull(@sg_estado_cliente,'') <> '' then  ' / '+isnull(@sg_estado_cliente,'')+'' else '' end +' </p>

	 <p style="text-align: right; margin-right: 270PX;"><strong>Entrega: </strong>'+CASE WHEN isnull(@hr_entrega_cliente,'') = '' THEN '' ELSE isnull(@hr_entrega_cliente,'') END +'</p>
		<div style="text-align: right;">	
		  <label><input type="checkbox" ' + CASE WHEN ISNULL(@ic_seg_entrega, '') = 'N' THEN '' ELSE 'checked' END + '> Segunda</label>
		  <label><input type="checkbox" ' + CASE WHEN ISNULL(@ic_ter_entrega, '') = 'N' THEN '' ELSE 'checked' END + '> Terça</label>
		  <label><input type="checkbox" ' + CASE WHEN ISNULL(@ic_qua_entrega, '') = 'N' THEN '' ELSE 'checked' END + '> Quarta</label>
		  <label><input type="checkbox" ' + CASE WHEN ISNULL(@ic_qui_entrega, '') = 'N' THEN '' ELSE 'checked' END + '> Quinta</label>
		  <label><input type="checkbox" ' + CASE WHEN ISNULL(@ic_sex_entrega, '') = 'N' THEN '' ELSE 'checked' END + '> Sexta</label>
		  <label><input type="checkbox" ' + CASE WHEN ISNULL(@ic_sab_entrega, '') = 'N' THEN '' ELSE 'checked' END + '> Sábado</label>
		  <label><input type="checkbox" ' + CASE WHEN ISNULL(@ic_dom_entrega, '') = 'N' THEN '' ELSE 'checked' END + '> Domingo</label>
		</div>
    <table>
        <tr>
            <th style="font-size:12px; width:10%;">Produto</th>
            <th style="font-size:12px; width:50%;">Descrição  ' + case when @nm_item_bonificado <> '' then '     **' + @nm_item_bonificado + '**     'else '' end + '</th>
            <th style="font-size:12px; width:5%;">QTD.</th>
            <th style="font-size:12px; width:5%;">UN.</th>
			<th style="font-size:12px; width:15%">Preço Unitário (R$)</th>
			<th style="font-size:12px; width:15%">Total (R$)</th>
        </tr>'

DECLARE @cd_controle                INT = 0
DECLARE @cd_item_consulta           INT = 0
DECLARE @Descricao			        varchar(200) = ''
Declare @Quantidade			        varchar(10) = ''
declare @nm_unidade_medida	        varchar(10) = ''
DECLARE @NCM		    		    varchar(60) = ''
DECLARE @ICMS				        varchar(60) = ''
DECLARE @vl_unitario_item_consulta	varchar(60) = ''
DECLARE @qt_item					varchar(60) = ''
DECLARE @vl_total_ipi_footer		float = 0
DECLARE @vl_total_icmsst			float = 0
DECLARE @vl_icms_st					float = 0
DECLARE @Produto					varchar(200) = ''
declare @vl_total_ipi_item_unitario varchar(200) = ''
declare @qt_total_item				float = 0
declare @qt_total_item_soma			float = 0
declare @vl_total_item_liquido		float = 0
declare @vl_total_linha_liquido float = 0


set @qt_total_item = (select distinct COUNT(cd_controle) from #ApresentacaoItens)

DECLARE item_cursor CURSOR FOR
SELECT 
	cd_controle, 
	cd_item_consulta,
	Descricao,
	Quantidade,
	nm_unidade_medida,
	vl_item_icms_st,
	vl_unitario_item_consulta,
	vl_total_ipi_unitario,
	qtItem,
	vl_total_ipi_footer,
	vl_icms_st,
	Produto,
	vl_total_linha_liquido
FROM #ApresentacaoItens
order by
  Descricao


OPEN item_cursor
FETCH NEXT FROM item_cursor INTO @cd_controle, @cd_item_consulta, @Descricao, @Quantidade, @nm_unidade_medida, @ICMS, @vl_unitario_item_consulta, @vl_total_ipi_item_unitario, @qt_item, @vl_total_ipi_footer, @vl_icms_st, @Produto,@vl_total_linha_liquido
--select * from consulta_itens where cd_consulta = 6944
WHILE @@FETCH_STATUS = 0
BEGIN
	set @qt_total_item_soma = @qt_total_item_soma + @Quantidade
	--set @vl_total_ipi = @vl_total_ipi + @vl_total_ipi_footer
	--set @vl_total_icmsst = @vl_total_icmsst + @vl_icms_st
	set @vl_total_item_liquido = isnull(@vl_total_item_liquido,0) + @vl_total_linha_liquido
	
    SET @html = @html + '
        <tr>
            <td style="font-size:12px; text-align:center; width:10%;">'+isnull(@Produto,'')+'</td>
			<td style="font-size:10px; text-align:left; width:50%;"><strong>'+isnull(@Descricao,'')+'</strong></td>
			<td style="font-size:12px; text-align:center; width:5%">'+isnull(@Quantidade,'')+'</td>
			<td style="font-size:12px; text-align:center; width:5%">'+isnull(@nm_unidade_medida,'')+'</td>
			<td style="font-size:12px; text-align:center; width:15%">'+isnull(@vl_unitario_item_consulta,'')+'</td>
			<td style="font-size:12px; text-align:center; width:15%">'+isnull(@qt_item,'')+'</td>
        </tr>'
    FETCH NEXT FROM item_cursor INTO @cd_controle, @cd_item_consulta, @Descricao, @Quantidade, @nm_unidade_medida, @ICMS, @vl_unitario_item_consulta,@vl_total_ipi_item_unitario,@qt_item,@vl_total_ipi_footer,@vl_icms_st,@Produto,@vl_total_linha_liquido
END

CLOSE item_cursor
DEALLOCATE item_cursor


--declare @vl_total_ipi_vc varchar(25) = ''
--declare @vl_total_icmsst_vc varchar(25) 

--set @vl_total_ipi_vc    = 'R$ ' + dbo.fn_formata_valor(@vl_total_ipi)
--set @vl_total_icmsst_vc = 'R$ '+dbo.fn_formata_valor(@vl_total_icmsst)
declare @vl_final  varchar(60) = ''
set @vl_final =dbo.fn_formata_valor(round(@vl_total_pedido_venda,2))
--set @vl_total_icmsst = convert(varchar,@vl_total_icmsst)

SET @html = @html + '
    <tr>
            <td style="font-size:12px; text-align:center; width:10%;"><strong>Total</strong></td>
			<td style="font-size:10px; text-align:left; width:50%;"></td>
			<td style="font-size:14px; text-align:center; width:5%"><strong>'+isnull(cast(@qt_total_item_soma as varchar),'')+'</strong></td>
			<td style="font-size:12px; text-align:center; width:5%"></td>
			<td style="font-size:12px; text-align:center; width:15%"></td>
			<td style="font-size:14px; text-align:center; width:15%"><strong>'+isnull(@vl_final,'')+ '</strong></td>
        </tr>
	</table>
	<div style="display: flex;justify-content: space-between;">
	<p>'+case when isnull(@nm_forma_pagamento,'') <> '' then + '<strong>Forma de Pagamento: </strong>'+isnull(@nm_forma_pagamento,'')+'' else ''end + '</p>
	<p>'+case when isnull(@nm_semana,'')  <> '' and isnull(@cd_criterio_visita,0) > 0 then + '<strong>Dia da Semana: </strong>'+isnull(@nm_semana,'')+'' else ''end + '</p>
	<p>'+case when isnull(@nm_itinerario,'') <> '' then + '<strong>Itinerário: </strong>'+isnull(@nm_itinerario,'')+'' else ''end + '</p>
		 
    </div>
		'+
	case when ISNULL(@ds_obs_fat_pedido,'') <> ''
		 then '<div class="section-title"><strong>Observações da Nota Fiscal</strong></div>
					<p>'+isnull(@ds_obs_fat_pedido,'')+'</p>'
		 else '' 
	end +
	case when ISNULL(@ds_relatorio,'') <> ''
		 then '<div class="section-title"><strong>Observações do Pedido</strong></div>
					<p>'+isnull(@ds_relatorio,'')+'</p>'
		 else ''
	end +'
	</body>
	</html>'


if isnull(@cd_pedido_venda,0) > 0
begin
  set @pdfName = 'Pedido_'+cast(@cd_pedido_venda as varchar)
end
else
begin
  set @pdfName = 'Proposta_'+cast(@cd_consulta as varchar)
end

select @html as RelatorioHTML, @pdfName as pdfName


go


------------------------------------------------------------------------------------------------------------------------------------------------------------
--Executando
------------------------------------------------------------------------------------------------------------------------------------------------------------
--Relatório do diário de Pedido (Egismob)
---exec pr_egismob_relatorio_pedido_regis'[ {"cd_consulta": 0, "cd_menu": 5428, "cd_parametro": 14, "cd_pedido_venda":25, "cd_usuario": 4645}]'


