IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_solicitacao_compra' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_solicitacao_compra

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_solicitacao_compra
-------------------------------------------------------------------------------
--pr_relatorio_solicitacao_compra
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
create procedure pr_relatorio_solicitacao_compra
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

--select * from #json
 --@dt_inicial, @dt_final , @cd_status , @cd_tecnico , @cd_tipo_defeito , @cd_marca_produto
-------------------------------------------------------------------------------------------------

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_requisicao_compra   = valor from #json where campo = 'cd_documento_form'
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

 --select @cd_relatorio

select
  top 1
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

select 
	   req.cd_requisicao_compra,
       req.dt_emissao_req_compra                                as dt_emissao_req_compra,
       req.dt_necessidade_req_compra                            as dt_necessidade_req_compra, 
	   req.dt_liberado_proc_compra,
       req.cd_tipo_requisicao                                   as cd_tipo_requisicao,
       req.cd_departamento,
       req.cd_aplicacao_produto                                 as cd_aplicacao_produto,
       req.cd_destinacao_produto,
       req.cd_centro_custo                                      as cd_centro_custo,
	   ic_liberado_proc_compra,
       cast(req.cd_departamento as varchar(10)) + ' - ' + dep.nm_departamento as nm_departamento,
       cast(req.cd_centro_custo as varchar(10)) + ' - ' + cc.nm_centro_Custo as nm_centro_Custo,
       plano.cd_mascara_plano_compra,
       plano.nm_plano_compra,
       tipo_req.nm_tipo_requisicao,
       IsNull(tipo_req.ic_tipo_requisicao, 'N') as  'ic_tipo_requisicao',
       Aplicacao.nm_aplicacao_produto as nm_aplicacao_produto, 
       destinacao.nm_destinacao_produto as nm_destinacao_produto,
       (Select top 1 nm_motivo_requisicao from Motivo_requisicao where cd_motivo_requisicao = req.cd_motivo_requisicao) as nm_motivo_requisicao,
       (Select top 1 nm_pais from pais where cd_pais = req.cd_pais) as nm_pais,
       (Select top 1 nm_tipo_importacao from tipo_importacao where cd_tipo_importacao = req.cd_tipo_importacao) as nm_tipo_importacao,
       tipo_req.ic_importacao,
       req.ds_requisicao_compra,
       usuario.nm_usuario,
       ( select top 1 x.nm_usuario 
         from Requisicao_Compra_Aprovacao rqap left outer join 
                 EGISADMIN.dbo.Usuario x on x.cd_usuario = rqap.cd_usuario_aprovacao
         where rqap.cd_requisicao_compra = req.cd_requisicao_compra) as nm_usuario_aprovacao,
      ( select top 1 rqap.dt_usuario_aprovacao
         from Requisicao_Compra_Aprovacao rqap 
         where rqap.cd_requisicao_compra = req.cd_requisicao_compra) as 'dt_usuario_aprovacao',
     usreq.nm_fantasia_usuario as Requisitante, 
	 tipo_req.ic_servico_tipo_requisicao,
     req.ds_obs_comprador,

	 --NOME EMPRESA
	     case when isnull(pce.cd_empresa,0) <> 0 
	  then ISNULL(efa.nm_empresa,'')
	  else ISNULL(e.nm_empresa, '')
	end                                     as nm_empresa,
	   --ENDEREÇO
    case when isnull(pce.cd_empresa,0) <> 0 
	  then isnull(efa.nm_endereco,'') + ' - ' + isnull(efa.cd_numero,'') + ' - ' +isnull(dbo.fn_formata_cep(efa.cd_cep),'') + ' - ' +isnull(efa.nm_bairro,'')
	  else isnull(e.nm_endereco_empresa,'') + ' - ' + isnull(e.cd_numero,'') + ' - ' + isnull(dbo.fn_formata_cep(e.cd_cep),'')+ ' - ' + isnull(e.nm_bairro_empresa,'')
	end                                     as nm_endereco_empresa,
	
   --CIDADE
	case when isnull(pce.cd_empresa,0) <> 0 
	  then isnull(cd.nm_cidade,'') + ' - '+ isnull(es.sg_estado,'') + ' - '+ isnull(pai.nm_pais,'')
	  else isnull(cid.nm_cidade,'') + ' - ' + isnull(est.sg_estado,'') + ' - ' + isnull(paii.nm_pais,'')
	end as nm_endereco_cidade,

	--FONE
	case when isnull(prs.cd_telefone_compra,'') <> '' 
	  then isnull(prs.cd_telefone_compra,'')
	  else case when isnull(pce.cd_empresa,0) <> 0 
	         then isnull(efa.cd_telefone,'')
	         else isnull(e.cd_telefone_empresa,'')
	       end
    end                                      as cd_telefone_empresa,

   --EMAIL
   case when isnull(prs.nm_email_setor_compra,'') <> '' 
     then isnull(e.nm_dominio_internet,'') + ' - ' + isnull(prs.nm_email_setor_compra,'')
	 else case when isnull(e.nm_email_internet,'') <> '' 
	        then isnull(e.nm_dominio_internet,'') + ' - ' + isnull(e.nm_email_internet,'')
			else isnull(e.nm_email_internet,'')
		    end
   end                                       as nm_email_empresa,

   case when isnull(pce.cd_empresa,0) <> 0
     then  + 'CNPJ: '+ isnull(dbo.fn_formata_cnpj(efa.cd_cnpj_empresa),'') + ' - ' + 'I.E: ' + isnull(efa.cd_ie_empresa,'')
		else + 'CNPJ: '+ isnull(dbo.fn_formata_cnpj(e.cd_cgc_empresa),'') + ' - ' + 'I.E: ' + isnull(e.cd_iest_empresa,'') end                   as CNPJ_empresa

		
		into
		#reqCompraCapa

from requisicao_compra req 
left outer join departamento dep                                 on dep.cd_departamento = req.cd_departamento
left outer join plano_compra plano                               on req.cd_plano_compra = plano.cd_plano_compra
left outer join centro_Custo CC                                  on cc.cd_centro_custo = req.cd_centro_custo
left outer join Aplicacao_Produto Aplicacao                      on aplicacao.cd_Aplicacao_produto = req.cd_Aplicacao_produto
left outer join destinacao_Produto destinacao                    on destinacao.cd_destinacao_produto = req.cd_destinacao_produto
left outer join tipo_requisicao tipo_req                         on tipo_req.cd_tipo_requisicao = req.cd_tipo_requisicao
left outer join egisadmin.dbo.usuario usuario                    on usuario.cd_usuario = req.cd_usuario
left outer join egisadmin.dbo.usuario usreq                      on usreq.cd_usuario = req.cd_requisitante

  left outer join Requisicao_Compra_Empresa pce	   with(nolock)  on pce.cd_requisicao_compra	   = req.cd_requisicao_compra
  left outer join Empresa_Faturamento efa          with(nolock)	 on efa.cd_empresa			       = pce.cd_empresa
  left outer join Pais pai                         with(nolock)	 on pai.cd_pais				       = efa.cd_pais
  left outer join Estado es                        with(nolock)	 on es.cd_estado			       = efa.cd_estado
  left outer join Cidade cd                        with(nolock)	 on cd.cd_cidade			       = efa.cd_cidade
											       
  left outer join EGISADMIN.dbo.Empresa e          with(nolock)  on e.cd_empresa			       = dbo.fn_empresa() -- pce.cd_empresa
  left outer join Pais paii                        with(nolock)	 on paii.cd_pais			       = e.cd_pais
  left outer join Estado est                       with(nolock)	 on est.cd_estado			       = e.cd_estado
  left outer join Cidade cid                       with(nolock)	 on cid.cd_cidade			       = e.cd_cidade
  left outer join Parametro_Suprimento prs         with(nolock)  on prs.cd_empresa			       = e.cd_empresa
  Left outer join EGISADMIN.dbo.Usuario us         with(nolock) on us.cd_usuario                    = @cd_usuario   
  where
	req.cd_requisicao_compra = @cd_requisicao_compra

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

select 
	   identity(int,1,1) as cd_controle,
	   reqi.cd_requisicao_compra, 
	   m.nm_fantasia_maquina,
       reqi.cd_item_requisicao_compra,
       reqi.cd_produto,
       reqi.qt_item_requisicao_compra,
       reqi.cd_servico,
       reqi.ds_item_requisicao_compra,
       reqi.nm_prod_requisicao_compra,
       rcf.nm_contato_fornecedor,
       rcf.nm_compra_fornecedor,
       rtrim(ltrim(rcf.cd_ddi_compra_fornecedor + ' '  +  rcf.cd_ddd_compra_fornecedor + ' ' + rcf.cd_fone_compra_fornecedor)) as TelefoneFornecedor,
       reqi.cd_pedido_venda,
       reqi.cd_item_pedido_venda,
       reqi.cd_unidade_medida,
       reqi.qt_liq_requisicao_compra,
       reqi.nm_obs_item_req_compra,
       reqi.ic_gera_coto_item_req_com,
       reqi.ic_pedido_item_req_compra,
       reqi.nm_marca_item_req_compra,
       reqi.cd_categoria_produto,
       reqi.cd_maquina,
       reqi.nm_unidade_medida,
       reqi.qt_liquido_req_compra,
       reqi.qt_bruto_req_compra,
       ( select sum(IsNull(x.qt_bruto_req_compra,0)) from requisicao_compra_item x
          where x.cd_requisicao_compra = reqi.cd_requisicao_compra 
          group by x.cd_requisicao_compra ) as qt_total_bruto_req_compra,
       ( select sum(IsNull(x.qt_item_requisicao_compra,0)) from requisicao_compra_item x
          where x.cd_requisicao_compra = reqi.cd_requisicao_compra 
          group by x.cd_requisicao_compra ) as qt_total_item_req_compra,
       reqi.qt_peso_req_compra,
       reqi.cd_item_pedido_compra,
       reqi.cd_pedido_compra,
       reqi.dt_item_nec_req_compra,
       dbo.fn_mascara_produto(reqi.cd_produto) as cd_mascara_produto,
       um.sg_unidade_medida,
       mp.sg_mat_prima,
       reqi.nm_medbruta_mat_prima,
       reqi.nm_medacab_mat_prima, reqi.nm_placa,
       case when REPLACE(IsNull(Cast(reqi.ds_obs_req_compra_item as varchar(2000)),''),CHAR(13),'') = '' then
         '' else reqi.ds_obs_req_compra_item end as ds_obs_req_compra_item, 
        ic_especial_grupo_produto,
       -- ELIAS 22/12/2003       
         p.nm_produto, 
		 p.nm_produto_complemento,
         s.nm_servico,
        c.nm_fantasia_cliente,
      pimp.cd_part_number_produto,
      pimp.vl_produto_importacao,
      cf.cd_mascara_classificacao,
      cast( p.qt_espessura_produto as varchar ) + ' x '+ 
      cast(p.qt_largura_produto as varchar)     + ' x ' + 
      cast(p.qt_comprimento_produto as varchar)  as 'Dimensao',
      reqi.qt_item_requisicao_compra * 
      isnull(pimp.vl_produto_importacao,0)       as 'Valor_Total_Item_Importacao',
      case when isnull(reqi.qt_peso_req_compra,0)>0 then
        isnull(reqi.qt_peso_req_compra,p.qt_peso_bruto)
      else
        p.qt_peso_bruto 
      end * 
      reqi.qt_item_requisicao_compra                    as Total_Peso, 
	  p.nm_fantasia_produto,
	  pc.vl_custo_produto                               as vl_custo_produto,
	  pc.vl_custo_medio_produto                         as vl_custo_medio_produto
		into
	  #reqCompraItem

from 
 requisicao_compra_item reqi           with (nolock) 
  left outer join Materia_Prima mp     with (nolock) on mp.cd_mat_prima = reqi.cd_mat_prima 
  left outer join Produto p            with (nolock) on p.cd_produto = reqi.cd_produto 
  left outer join Unidade_Medida um    with (nolock) on um.cd_unidade_medida = reqi.cd_unidade_medida
  left outer join Grupo_Produto gp     with (nolock) on gp.cd_grupo_produto = p.cd_grupo_produto 
  left outer join Servico s            with (nolock) on s.cd_servico = reqi.cd_servico 
  left outer join Maquina m            with (nolock) on reqi.cd_maquina = m.cd_maquina
  left outer join Pedido_Venda pv with (nolock) on pv.cd_pedido_venda = reqi.cd_pedido_venda
  left outer join Cliente c       with (nolock) on c.cd_cliente = pv.cd_cliente       
  left outer join Produto_Importacao pimp with (nolock) on pimp.cd_produto = p.cd_produto
  left outer join Produto_Fiscal pf       with (nolock) on pf.cd_produto   = p.cd_produto
  left outer join Classificacao_Fiscal cf with (nolock) on cf.cd_classificacao_fiscal = pf.cd_classificacao_fiscal
  left outer join Requisicao_Compra_Fornecedor rcf with (nolock) on rcf.cd_requisicao_compra   = reqi.cd_requisicao_compra and
                                                                    rcf.cd_item_req_fornecedor = reqi.cd_item_requisicao_compra
  left outer join Produto_Custo	pc	   with (nolock) on    pc.cd_produto = p.cd_produto													
 
 where 
   (reqi.cd_requisicao_compra = @cd_requisicao_compra)

order by 
  reqi.cd_requisicao_compra,
  reqi.cd_item_requisicao_compra

-------------------------------------------------------------------------------------------------------------- --
declare @dt_necessi_req          datetime
declare @nm_requisitante         nvarchar(60)
declare @nm_dpto                 nvarchar(60)
declare @nm_centro_custo         nvarchar(60)
declare @cd_centro_custo         int = 0
declare @cd_requisicao           int = 0
declare @nm_tipo_requisicao      nvarchar(60)
declare @cd_mascara_plano        nvarchar(60)
declare @nm_plano_compra         nvarchar(60)
declare @nm_motivo_requisicao    nvarchar(60)
declare @cd_aplicacao            int = 0
declare @nm_aplicacao_produto    nvarchar(60)
declare @cd_destinacao_produto   int = 0
declare @nm_destinacao_produto   nvarchar(60)
declare @nm_pais_rel             nvarchar(60)
declare @nm_tipo_importacao      nvarchar(60)
declare @nm_compra_fornecedor    nvarchar(60)
declare @ds_obs_req_compra_item  nvarchar(400)
declare @nm_usuario_aprovacao    nvarchar(60)
declare @ds_obs_comprador        nvarchar(100)
declare @qt_total_bruto_req_compra float = 0
declare @qt_total_item_req_compra  float = 0
declare @nm_usuario              nvarchar(60)  
declare @nm_produto_rel          nvarchar(60) 
-------------------------------------------------------------------------------------------------------------- 
declare @dt_emissao_req          datetime
select 
	 @dt_emissao_req            = dt_emissao_req_compra,      
	 @dt_necessi_req            = dt_necessidade_req_compra,
	 @nm_requisitante           = Requisitante,
	 @nm_dpto                   = nm_departamento,
	 @nm_centro_custo           = nm_centro_Custo,
	 @cd_requisicao             = cd_tipo_requisicao,
	 @nm_tipo_requisicao        = nm_tipo_requisicao,
	 @cd_mascara_plano          = cd_mascara_plano_compra,
	 @nm_plano_compra           = nm_plano_compra,
     @nm_motivo_requisicao      = nm_motivo_requisicao,
	 @cd_aplicacao              = cd_aplicacao_produto,
	 @nm_aplicacao_produto      = nm_aplicacao_produto,
	 @cd_destinacao_produto     = cd_destinacao_produto,
	 @nm_destinacao_produto     = nm_destinacao_produto,
	 @nm_pais_rel               = nm_pais,
	 @nm_tipo_importacao        = nm_tipo_importacao,
	 @nm_usuario_aprovacao      = nm_usuario_aprovacao,
	 @ds_obs_comprador          = ds_obs_comprador,
	 @nm_usuario                = nm_usuario,
	 @cd_centro_custo           = cd_centro_custo
from #reqCompraCapa  

select 
	@nm_compra_fornecedor      = nm_compra_fornecedor,
	@ds_obs_req_compra_item    = ds_obs_req_compra_item,
	@qt_total_bruto_req_compra = qt_total_bruto_req_compra,
	@qt_total_item_req_compra  = qt_total_item_req_compra
from #reqCompraItem
--------------------------------------------------------------------------------------------------------------
set @html_geral = '<td style="width: 20%; text-align: center;">
						<p><strong>Requisição de Compra: '+cast(isnull(@cd_requisicao_compra,0) as nvarchar(20))+'</strong></p>
						<p><strong>Data Requisição:</strong> '+isnull(dbo.fn_data_string(@dt_emissao_req),'')+'</p>
						<p><strong>Necessidade:</strong> '+isnull(dbo.fn_data_string(@dt_necessi_req),'')+'</p>
					</td>
				</tr>
			</table>       
			<p class="section-title" style=" text-align: center;">Solicitação de Compras</p> 
			<table>
            <tr style=" text-align: center;">
                <td><strong>Requisitante: </strong>'+isnull(@nm_requisitante,'')+'</td>
                <td><strong>Depto: </strong>'+isnull(@nm_dpto,'')+'</td>
                <td><strong>Centro de Custo: </strong>'+isnull(@nm_centro_custo,'')+'</td>
            </tr>
        </table>
        <table>
            <tr>
                <th>Tipo Requisição:</th>
                <td>('+cast(isnull(@cd_requisicao,0) as nvarchar(20))+') '+isnull(@nm_tipo_requisicao,'')+'</td>
                <th>Destinação:</th>
                <td> ('+cast(isnull(@cd_destinacao_produto,0) as nvarchar(20))+') '+isnull(@nm_destinacao_produto,'')+'</td>
            </tr>
            <tr>
                <th>Plano de Compras </th>
                <td> ('+cast(isnull(@cd_mascara_plano,0) as nvarchar(20))+') '+isnull(@nm_plano_compra,'')+'</td>
                <th>Procedência</th>
                <td>'+isnull(@nm_pais_rel,'')+'</td>
            </tr>
            <tr>
                <th>Aplicação:</th>
                <td>('+cast(isnull(@cd_aplicacao,0) as nvarchar(20))+') '+isnull(@nm_aplicacao_produto,'')+'</td>
                <th>Mét. de Embarque</th>
                <td>'+isnull(@nm_tipo_importacao,'')+'</td>
            </tr>
            <tr>
                <th>Motivo:</th>
                <td>'+isnull(@nm_motivo_requisicao,'')+'</td>
                <th>Fornecedor:</th>
                <td>'+isnull(@nm_compra_fornecedor,'')+'</td>
            </tr>
        </table>
        <table>
            <tr>
                <th>Item</th>
				<th>Código</th>
				<th>Fantasia - Descrição</th>
				<th>Marca</th>
				<th>Un.</th>
                <th>Qtd.</th>
				<th>Custo</th>
                <th>Necessidade</th>
                <th>Disponivel</th>
                <th>P.Bruto</th>
                <th>Cons.Médio</th>
                <th>P.V.</th>
                <th>Item P.V</th>
            </tr>'			   	

--------------------------------------------------------------------------------------------------------------
declare @id int = 0

while exists ( select top 1 cd_controle from #reqCompraItem)
begin

	select top 1
		@id                         = cd_controle,

		@html_geral = @html_geral +'
            <tr style="text-align: center;">
                <td>'+cast(isnull(cd_controle,0) as nvarchar(20))+'</td>
				<td>'+cast(isnull(cd_mascara_produto,0) as nvarchar(20))+'</td>
				<td style="text-align: left;">'+isnull(nm_fantasia_produto,'')+' - '+isnull(nm_produto,'')+'</td>
				<td>'+isnull(nm_marca_item_req_compra,'')+'</td>
				<td>'+isnull(sg_unidade_medida,'')+'</td>
                <td>'+cast(isnull(qt_item_requisicao_compra,0) as nvarchar(20))+'</td>
				<td>'+cast(isnull(vl_custo_produto,'') as nvarchar(20))+'</td>
                <td>'+isnull(dbo.fn_data_string(dt_item_nec_req_compra),'')+'</td>
                <td>'+cast(isnull(qt_peso_req_compra,0) as nvarchar(20))+'</td>
                <td>'+cast(isnull(qt_bruto_req_compra,0) as nvarchar(20))+'</td>
                <td>'+cast(isnull(vl_custo_medio_produto,0) as nvarchar(20))+'</td>
                <td>'+cast(isnull(cd_pedido_venda,0) as nvarchar(20))+'</td>
                <td>'+cast(isnull(cd_item_pedido_venda,0) as nvarchar(20))+'</td>
            </tr>'
     from #reqCompraItem
	 delete from #reqCompraItem where cd_controle = @id
 end
 
--------------------------------------------------------------------------------------------------------------------
declare @html_totais nvarchar(max)=''
declare @titulo_total varchar(500)=''

set @html_rodape =
           '</table>
		    <div class="section-title">
			  <p>Total Item: '+cast(isnull(@qt_total_item_req_compra,0) as nvarchar(20))+'</p>
			  <p>Total Bruto: '+cast(isnull(@qt_total_bruto_req_compra,0) as nvarchar(20))+'</p>
           </div>
		   <table style="width: 100%;">
            <tr>
                <td style="text-align: left;">
                    <div>
                        <p style="font-size: 20px;"><b>Observações dos Itens</b></p>
                        <p>
                            '+isnull(@ds_obs_req_compra_item,'')+'
                        </p>
                        <p>
                            Observações: '+isnull(@ds_obs_comprador,'')+'
                        </p>
                    </div>
                </td>
            </tr>
        </table>
        <table>
           <tr >
                <td>
                    <div>
                        <p style="text-align: Left;"> 
                            <strong>Aprovada:</strong> '+isnull(@nm_usuario_aprovacao,'')+'
                        </p>
                        <p style="text-align: right;"> 
                            <strong>Impressão:</strong> '+@data_hora_atual+'
                        </p>
                    </div>
                </td>
            </tr>
            <tr >
                <td>
                    <div>
                        <p style="text-align: Left;"> 
                            <strong>Usuário:</strong> '+isnull(@nm_usuario,0)+'
                        </p>
                        <p style="text-align: right;"> 
                           <strong> RC:</strong> '+cast(isnull(@cd_requisicao_compra,0) as nvarchar(20))+'
                        </p>
                    </div>
                </td>
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
exec pr_relatorio_solicitacao_compra 249,'' 
------------------------------------------------------------------------------

