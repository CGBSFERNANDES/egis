IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_cotacao_compras' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_cotacao_compras

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_cotacao_compras
-------------------------------------------------------------------------------
--pr_relatorio_cotacao_compras
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
create procedure pr_relatorio_cotacao_compras
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
declare @cd_cotacao             int = 0
declare @nm_usuario             int = 0 
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
  select @cd_cotacao             = valor from #json where campo = 'cd_documento_form'
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
		@nm_fantasia_empresa	    = isnull(e.nm_empresa,''),
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
            margin: 0;
            padding: 0;
            background-color: #f9f9f9;
        }

        .container {
            width: 95%;
            margin: 20px auto;
            background-color: #fff;
            padding: 20px;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
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
            padding: 8px;
            text-align: center;
        }

        th {
            background-color: #f2f2f2;
            color: #333;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .header {
            text-align: center;
            padding-bottom: 20px;
        }

		.section-title {
			background-color: '+isnull(@nm_cor_empresa,'')+';
			color: white;
			padding: 5px 15px; 
			margin: 10px;
			border-radius: 5px;
			font-size: 120%;
			display: flex; 
			justify-content: space-between; 
			align-items: center; 
			width: 97%; 
			position: relative;
		}

        img {
            max-width: 250px;
        }

        .company-info {
            text-align: right;
            margin-bottom: 10px;
        }

        .proposal-info {
            text-align: left;
            margin-bottom: 10px;
        }

        .report-date-time {
            text-align: right;
            margin-bottom: 5px;
        }

        .title {
            color: #e2011b;
            text-align: center;
        }

        .assinatura {
            display: flex;
            justify-content: center;
            align-items: center;
            text-align: center;
        }

        .textocorpo {
            text-align: justify;
            margin: 15px 110px;
        }
    </style>
</head>

<body>
    <div class="container">
        <table>
            <tr>
                <td style="width: 20%; text-align: center;"><img src="'+@logo+'" alt="Logo da Empresa">
		<td style="width: 80%; text-align: center;">
			<p class="title">'+@nm_fantasia_empresa+'</p>
		    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
		    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
		    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
		 </td>
            </tr>
        </table>'

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

--------------------------------------------------------------------------------------------------------------------------
 select 
      cc.*,
      rtrim(ltrim(f.nm_fantasia_fornecedor)) as nm_fantasia_fornecedor,
      f.nm_razao_social                      as nm_razao_social,
      f.cd_ddd                               as cd_ddd,
      f.cd_telefone                          as cd_telefone,
      f.cd_fax                               as cd_fax, 
	  IsNull(fc.cd_email_contato_forneced, IsNull(f.nm_email_fornecedor, '')) as nm_email_fornecedor,
      fc.nm_contato_fornecedor               as nm_contato_fornecedor,
      d.nm_departamento                      as nm_departamento,
      cond_pagto.nm_condicao_pagamento       as nm_condicao_pagamento,
      cp.nm_comprador                        as nm_comprador

	  into
	  #cotacaCapaRel
    from cotacao cc
    left outer join fornecedor f                  on f.cd_fornecedor = cc.cd_fornecedor
    left outer join fornecedor_contato fc         on cc.cd_fornecedor = fc.cd_fornecedor and cc.cd_contato_fornecedor = fc.cd_contato_fornecedor
    left outer join departamento d                on fc.cd_departamento = d.cd_departamento
    left outer join condicao_pagamento cond_pagto on cc.cd_condicao_pagamento = cond_pagto.cd_condicao_pagamento
	left outer join cotacao_item i                 on i.cd_cotacao             = cc.cd_cotacao
    left outer join comprador cp                  on cp.cd_comprador          = cc.cd_comprador
	left outer join produto_custo  pc             on pc.cd_produto            = i.cd_produto
    left outer join requisicao_compra rc          on rc.cd_requisicao_compra  = i.cd_requisicao_compra
    left outer join Requisicao_Compra_Item rci    on rci.cd_requisicao_compra = i.cd_requisicao_compra
	
    where 
      rc.cd_requisicao_compra = @cd_cotacao
	   and
  isnull(rc.ic_reprovada_req_compra,'N') = 'N'
  and
  ISNULL(rci.cd_pedido_compra,0) = 0
  and
  rc.cd_status_requisicao<>3
    order by cc.cd_cotacao
--------------------------------------------------------------------------------------------------------------
declare @cd_estado int
declare @pc_icms   decimal(25,4)

set @pc_icms   = 0.00
---------------------------------------
select
  @cd_estado = isnull(e.cd_estado,26)
from
  egisadmin.dbo.empresa e
where
  e.cd_empresa = dbo.fn_empresa()


----------------------------------------
select 
@pc_icms = isnull(pc_aliquota_icms_estado,0)
from
estado_parametro
where
cd_estado = @cd_estado

----------------------------------------

Select 
  identity(int,1,1)                            as cd_identitificacao,
  cot_item.*, 
  (case 
    when IsNull(cot_item.cd_servico,0) = 0 then 
      p.nm_fantasia_produto 
    else 
      s.nm_servico 
  end )                                                                     as nm_fantasia_produto,
  Unidade_medida.sg_unidade_medida as sg_unidade_medida, 
  IsNull(fs.nm_referencia_fornecedor, fp.nm_referencia_fornecedor) as nm_referencia_fornecedor, 
  (case 
    when ( ( IsNull(cot_item.cd_servico,0) > 0 ) and ( fs.nm_servico_fornecedor <> '' ) ) then 
      fs.nm_servico_fornecedor + ' ' + cast(fs.ds_servico_fornecedor as varchar(8000))
    when ( ( IsNull(cot_item.cd_produto,0) > 0 ) and ( fp.nm_produto_fornecedor <> '' ) ) then
      ltrim(
        --Nome do Produto no Fornecedor
        (case when ( fp.nm_produto_fornecedor is not null ) and (fp.nm_produto_fornecedor <> '')
          then fp.nm_produto_fornecedor + ' '
          else ''
        end) + 
        --Descrição do produto no Fornecedor
        (case when ( cast(fp.ds_produto_fornecedor as varchar(2)) <> '' )
          then cast(fp.ds_produto_fornecedor as varchar(8000)) + ' '
          else ''
        end) + 
        --Observação do Produto pelo Fornecedor
        (case when ( cast(fp.ds_observacao_produto as varchar(2)) <> '' )
          then cast(fp.ds_observacao_produto as varchar(8000)) + ' '
          else ''
        end) + 
        --Referência pelo Fornecedor
        (case when ( fp.nm_referencia_fornecedor is not null ) and (fp.nm_referencia_fornecedor <> '')
          then IsNull(fp.nm_referencia_fornecedor,'') + ' '
          else ''
        end))
    when ( IsNull(cot_item.cd_produto,0) > 0 ) then
      cp.nm_compra_produto    
    else
      ''
  end) as nm_produto_fornecedor,
  dbo.fn_mascara_produto(cot_item.cd_produto) as Codigo,
  gp.ic_especial_grupo_produto, 
   p.nm_produto,
  cot.ds_cotacao, cast(isnull(cot_item.ds_item_cotacao,'')as varchar(500))+ CHAR(13)+isnull(cot_item.nm_medbruta_mat_prima,'') as ds_item_cot_dim,
   p.nm_complemento_produto, p.nm_produto_complemento,
case when isnull(cfe.cd_classificacao_fiscal,0) > 0 then isnull(cfe.pc_icms_classif_fiscal,0)
else @pc_icms end                       as pc_icms,
p.nm_marca_produto as nm_marca_produto
   


into
#atributoItensRel
from 
  Cotacao_Item cot_item with (nolock, index(PK_Cotacao_Item))
  left outer join unidade_medida                         with (nolock)                                  on unidade_medida.cd_unidade_medida = cot_item.cd_unidade_medida
  left outer join produto p                              with (nolock, index(pk_produto))               on p.cd_produto  = cot_item.cd_produto
  left outer join Cotacao cot                            with (nolock, index(pk_cotacao))               on cot.cd_cotacao = cot_item.cd_cotacao
  left outer join Fornecedor_Produto fp                  with (nolock, index(pk_fornecedor_produto))    on fp.cd_fornecedor = cot.cd_fornecedor and fp.cd_produto = cot_item.cd_produto 
  left outer join Produto_Compra cp                      with (nolock, index(pk_produto_compra))        on cp.cd_produto = cot_item.cd_produto
  left outer join Grupo_Produto gp                       with (nolock, index(pk_grupo_produto))         on gp.cd_grupo_produto = p.cd_grupo_produto
  left outer join Fornecedor_Servico fs                  with (nolock, index(pk_fornecedor_servico))    on fs.cd_fornecedor = cot.cd_fornecedor and fs.cd_servico = cot_item.cd_servico
  left outer join Servico s                              with (nolock, index(pk_servico))               on s.cd_servico = cot_item.cd_servico
  left outer join produto_fiscal pf                                                                     on pf.cd_produto               = p.cd_produto
  left outer join classificacao_fiscal cf                                                               on cf.cd_classificacao_fiscal  = pf.cd_classificacao_fiscal
  left outer join produto_custo  pc                                                                     on pc.cd_produto            = cot_item.cd_produto
  left outer join requisicao_compra rc                                                                  on rc.cd_requisicao_compra  = cot_item.cd_requisicao_compra
  left outer join Requisicao_Compra_Item rci                                                            on rci.cd_requisicao_compra = cot_item.cd_requisicao_compra
  left outer join classificacao_fiscal_estado cfe                                                       on cfe.cd_classificacao_fiscal = pf.cd_classificacao_fiscal and
																																		cfe.cd_estado               = @cd_estado

where (rc.cd_requisicao_compra = @cd_cotacao) and
      (
       (ic_tipo_item = 'P') or
       (ic_tipo_item is null)
      )  and
  isnull(rc.ic_reprovada_req_compra,'N') = 'N'
  and
  ISNULL(rci.cd_pedido_compra,0) = 0
  and
  rc.cd_status_requisicao<>3
order by
  cot_item.cd_item_cotacao
--------------------------------------------------------------------------------------------------------------
	  declare @nm_fantasia_fornecedor           nvarchar(60)
	  declare @nm_razao_social                  nvarchar(60)
      declare @cd_ddd                           nvarchar(10)
	  declare @cd_telefone_rel                  nvarchar(25)
	  declare @cd_fax                           nvarchar(25)
	  declare @nm_email_fornecedor              nvarchar(60)
	  declare @nm_condicao_pagamento_rel        nvarchar(60)
	  declare @nm_comprador                     nvarchar(60)
	  declare @nm_departamento                  nvarchar(60)
	  declare @nm_contato_fornecedor            nvarchar(60)
	  declare @dt_cotacao                       datetime
	  declare @ds_cotacao                       nvarchar(150)
	  declare @vl_frete                         float = 0
	  declare @cd_requisicao_compra             int = 0 
	  declare @vl_item_cotacao                  float = 0 
-------------------------------------------------------------------------------------------------------------
select 
	@nm_fantasia_fornecedor    = nm_fantasia_fornecedor,
	@nm_razao_social           = nm_razao_social,
	@cd_ddd                    = cd_ddd,
	@cd_telefone_rel           = cd_telefone,
	@cd_fax                    = cd_fax,
	@nm_email_fornecedor       = nm_email_fornecedor,
    @nm_email_fornecedor       = nm_email_fornecedor,
	@nm_condicao_pagamento_rel = nm_condicao_pagamento,
	@nm_comprador              = nm_comprador,
	@nm_departamento           = nm_departamento,
	@nm_contato_fornecedor     = nm_contato_fornecedor,
	@dt_cotacao                = dt_cotacao,
	@ds_cotacao				   = ds_cotacao

from 
#cotacaCapaRel

select 
	    @cd_requisicao_compra	   = cd_cotacao,
		@vl_frete                  = vl_frete_item_cotacao
from #atributoItensRel
select 

	    @vl_item_cotacao           = sum(vl_item_cotacao)
from #atributoItensRel

--select @cd_requisicao_compra 
--------------------------------------------------------------------------------------------------------------
set @html_geral = '<table style="width: 100%;">
            <tr>
                <td style="display: flex; flex-direction: column; gap: 20px;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">

                        <div style="text-align: left; width: 45%;">
                            <p><strong>Cliente/Fornecedor:</strong> '+isnull(@nm_razao_social,'')+'</p>
                            <p><strong>A/C:</strong> '+isnull(@nm_contato_fornecedor,'')+' </p>
                            <p><strong>Depto:</strong> '+isnull(@nm_departamento,'')+'</p>
                        </div>
                        <div style="text-align: left;">
							<p style="font-size:20px;"> '+isnull(@nm_fantasia_fornecedor,'')+' </p>
                            <p><strong>E-mail:</strong> '+isnull(@nm_email_fornecedor,'')+' </p>
                            <p><strong>Telefone:</strong> ('+isnull(@cd_ddd,0)+') '+isnull(@cd_telefone_rel,0)+'</p>
                            <p><strong>Fax:</strong> '+isnull(@cd_fax,'')+'</p>
                
                        </div>
                    </div>
                </td>
            </tr>
        </table>
		<div class="section-title">
			<p style="font-size: 20px; margin: 0;flex: 1;text-align:center;">COTAÇÃO DE COMPRA Nº '+cast(isnull(@cd_requisicao_compra,0)as nvarchar(15))+'</p>
			<p style="margin: 0; padding-left: 15px;position: absolute; right: 15px;">Necessidade: '+isnull(dbo.fn_data_string(@dt_cotacao),'')+'</p>
		</div>
 
        <table>
            <tr>
                <th>Item</th>
				<th>Código</th> 
				<th>Descrição</th>
				<th>Marca</th>
                <th>Un.</th>
				<th>Qtd.</th>
                <th>Ref.Fornecedor</th>
				<th>Fantasia</th>
                <th>Vlr.unit</th>
                <th>%ICMS</th>
                <th>%IPI</th>
                <th>Vlr.Total</th>
                <th>Entrega</th>
                <th>Req.</th>
                <th>Req. Item</th>
            </tr>'
					   	

--------------------------------------------------------------------------------------------------------------
declare @id int = 0
while exists ( select top 1 cd_identitificacao from #atributoItensRel)
begin
	select top 1
		@id                         = cd_identitificacao,

		@html_geral = @html_geral +'<tr>
									  <td>'+cast(isnull(cd_item_cotacao,0)as nvarchar(10))+'</td>	
									  <td>'+cast(isnull(Codigo,0)as nvarchar(10))+'</td>
									  <td>'+isnull(nm_produto,'')+'</td>				  
									  <td>'+isnull(nm_marca_produto,'')+'</td>
									  <td>'+isnull(sg_unidade_medida,'')+'</td>
									  <td>'+cast(isnull(qt_item_cotacao,'')as nvarchar(15))+'</td>							  
									  <td>'+isnull(nm_produto_fornecedor,'')+'</td>
									  <td>'+isnull(nm_fantasia_produto,'')+'</td>
									  <td>'+cast(isnull(dbo.fn_formata_valor(vl_item_cotacao),0)as nvarchar(10))+'</td>
									  <td>'+cast(isnull(dbo.fn_formata_valor(pc_icms_item_cotacao),0)as nvarchar(10))+'</td>
									  <td>'+cast(isnull(dbo.fn_formata_valor(pc_ipi_item_cotacao),0)as nvarchar(10))+'</td>
									  <td>'+cast(isnull(dbo.fn_formata_valor(vl_item_cotacao),0)as nvarchar(10))+'</td>
									  <td>'+isnull(dbo.fn_data_string(dt_entrega_item_cotacao),'')+'</td>
									  <td>'+cast(isnull(cd_requisicao_compra,0)as nvarchar(20))+'</td>
									  <td>'+cast(isnull(cd_item_requisicao_compra,0)as nvarchar(20))+'</td>
								  </tr>'
						
     from #atributoItensRel
	 delete from #atributoItensRel where cd_identitificacao = @id
 end
--------------------------------------------------------------------------------------------------------------------
declare @html_totais nvarchar(max)=''
declare @titulo_total varchar(500)=''

set @html_rodape =
   ' </table>
        <table>
            <tr>
                    <td style="display: flex; flex-direction: column; gap: 20px;">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
    
                            <div style="text-align: left; width: 45%;">
                                <p><strong>Condição Pagamento: '+isnull(@nm_condicao_pagamento_rel,'')+'</strong> </p>
                                <p><strong>Observação da Requisição:</strong> </p>
                                <p><strong></strong> '+isnull(@ds_cotacao,'')+'</p>
                            </div>
                            <div>
								<p><strong>Comprador:</strong> '+isnull(@nm_comprador,'')+' </p>
								<p><strong>Frete:</strong> '+cast(isnull(dbo.fn_formata_valor(@vl_frete),0)as nvarchar(15))+'  </p>
                            </div>
							<div>
                                <p><strong>Total:'+cast(isnull(dbo.fn_formata_valor(@vl_item_cotacao),0)as nvarchar(10))+'</strong> </p>
                            </div>
                        </div>
                    </td>
            </tr>
        </table>
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
--exec pr_relatorio_cotacao_compras 250,'' 
------------------------------------------------------------------------------

