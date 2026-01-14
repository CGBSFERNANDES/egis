IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_entrada_saida_ordem_servico' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_entrada_saida_ordem_servico

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_entrada_saida_ordem_servico
-------------------------------------------------------------------------------
--pr_relatorio_entrada_saida_ordem_servico
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
create procedure pr_relatorio_entrada_saida_ordem_servico
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

----------------------------------------------------------------------------------------------
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
  select @cd_parametro           = valor from #json where campo = 'cd_parametro'
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
  @dt_final         = dt_final,
  @dt_inicial       = dt_inicial,
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
		.letra{
			font-size: 14px;
			font-weight: bold;
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
  
  
set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
--set @dt_inicial = '05/01/2025'
--set @dt_final = '06/28/2025'

if isnull(@cd_parametro,0) = 2    
 begin    
  select * from #RelAtributo    
  return    
end    
--------------------------------------------------------------------------------------------------------------------------
--- select cliente
select 
  IDENTITY(int,1,1)            as cd_controle,
  os.cd_ordem_servico		   as cd_ordem_servico,
  c.cd_cliente                 as cd_cliente,
  c.nm_fantasia_cliente        as nm_fantasia_cliente,
  dbo.fn_data_string(os.dt_ordem_servico) as dt_ordem_servico,
  os.ds_def_cli_ordem_servico  as ds_def_enc_ordem_servico,
  os.vl_total_ordem_servico    as vl_ordem_servico,
  osc.vl_desconto              as vl_desc_ordem_servico,
  osc.vl_custo_ordem_servico   as vl_custo_financeiro,
  dbo.fn_data_string(osc.dt_compra) as dt_compra,
  osc.pc_taxa_bancaria         as pc_taxa_bancaria,
  osc.vl_final_ordem_servico   as vl_final_ordem_servico,
  fp.cd_forma_pagamento        as cd_forma_pagamento,
  fp.nm_forma_pagamento        as nm_forma_pagamento,
  dbo.fn_data_string(osc.dt_entrega) as dt_entrega,
  osc.qt_dia_garantia          as qt_dia_garantia,
  f.nm_fantasia_fornecedor     as nm_fantasia_fornecedor, 
   case when isnull(osc.dt_pagamento,'') = '' 
  then 'Data Pagamento Não Preenchida' else dbo.fn_data_string(isnull(osc.dt_pagamento,'') + 180)  end     garantia,
  --osc.vl_final_ordem_servico   as vl_final_ordem_servico,
  case when 
  	  isnull(osc.cd_forma_pagamento,0) in (1,6) 
  	  then ''
  else
      (isnull(osc.vl_pagamento,0) * isnull(osc.pc_taxa_bancaria,0)) / 100 end as vl_desconto,
   case when 
  	  isnull(osc.cd_forma_pagamento,0) in (1,6) 
  	  then ''
  else
  isnull(osc.vl_pagamento,0)  - (isnull(osc.vl_pagamento,0) * isnull(osc.pc_taxa_bancaria,0)) / 100 end as vl_real,
  osc.vl_margem_orcamento      as vl_margem_orcamento,
  osc.vl_pagamento             as vl_pagamento,
  isnull(osc.vl_pagamento,0) - isnull(osc.vl_custo_ordem_servico,0) as vl_liquido,
 dbo.fn_formata_valor((isnull(osc.vl_final_ordem_servico,0) - isnull(osc.vl_custo_ordem_servico,0)) * 100 / osc.vl_final_ordem_servico) as vl_margem,
 (isnull(osc.vl_final_ordem_servico,0) - isnull(osc.vl_custo_ordem_servico,0)) * 100 / osc.vl_final_ordem_servico as vl_margemRel,
  case when 
  	  isnull(osc.cd_forma_pagamento,0) in (1,6) 
  	  then osc.vl_pagamento 
  	else
  	  0.00 end               as pix_dinheiro
	  
 into
 #Entrada_saida_Ordem_rel

from ordem_servico os 
  left outer join cliente c                   on c.cd_cliente = os.cd_cliente 
  left outer join ordem_servico_orcamento osc on osc.cd_ordem_servico = os.cd_ordem_servico
  left outer join Forma_Pagamento fp          on fp.cd_forma_pagamento = osc.cd_forma_pagamento 
  left outer join Fornecedor f                on f.cd_fornecedor = osc.cd_fornecedor
where
osc.dt_entrega between @dt_inicial and @dt_final
--case when isnull(osc.dt_pagamento,'') = '' then osc.dt_pagamento else os.dt_ordem_servico end between @dt_inicial and @dt_final
--osc.dt_entrega between @dt_inicial and @dt_final 
and 
isnull(osc.vl_pagamento,0)  > 0
and
os.cd_status_ordem_servico not in (5,6) --5 Reprovada, 6 Cancelada
  
order by
 osc.cd_ordem_servico
------------------------------------------------------------------------------------------------------------		 
   
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #Entrada_saida_Ordem_rel  
  return  
 end  
--------------------------------------------------------------------------------------------------------------
 declare 
	@vl_cliente                   int  = 0,
	@vl_venda_cliente             float = 0,
	@vl_real                      float = 0,
	@vl_desconto                  float = 0,
	@pc_taxa_bancaria_total       float = 0,
	@pix_dinheiro                 float = 0,
	@vl_custo_financeiro_total    float = 0,
	@vl_final_ordem_servico_total float = 0,
	@vl_margem_orcamento_total    float = 0,
	@vl_liquido                   float = 0,
	@vl_margem                    float = 0
 select 
	@vl_cliente                   = count(cd_cliente),
	@vl_venda_cliente             = sum(vl_pagamento),
	@vl_real                      = SUM(vl_real),
	@vl_liquido                   = SUM(vl_liquido),
	@vl_desconto                  = sum(vl_desconto),
	@vl_margem                    = SUM(vl_margemRel),
	@pc_taxa_bancaria_total       = sum(pc_taxa_bancaria),
	@pix_dinheiro                 = sum(pix_dinheiro),
	@vl_custo_financeiro_total    = SUM(vl_custo_financeiro),
	@vl_final_ordem_servico_total = sum(vl_final_ordem_servico),
	@vl_margem_orcamento_total    = sum(vl_margem_orcamento)
 from #Entrada_saida_Ordem_rel

--------------------------------------------------------------------------------------------------------------
set @html_geral = '     <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 22%;">'+isnull(@titulo,'')+'</p>  
    </div>
	<div>
    <table>  
		<tr class="tamanho">
		  <th>Entrega</th>
		  <th>O.S</th>
		  <th>Emissão</th>
		  <th>Cliente</th>		  
		  <th>Defeito</th>
		  <th>Venda Cliente R$</th>
		  <th>Desconto</th>
		  <th>Taxa %PagBank</th>
		  <th>Pix ou Dinheiro</th>
		  <th>Custo</th>
		  <th>Fornecedor</th>
		  <th>Compra</th>
		  <th>Resultado Final $</th>
		  <th>Margem %</th>
		  <th>Form. Pagamento</th>		  
		  <th>Garantia</th>
		  <th>Data Garantia</th>
		</tr>'
					   
--------------------------------------------------------------------------------------------------------------
DECLARE @id int = 0 

WHILE EXISTS (SELECT TOP 1 cd_controle FROM #Entrada_saida_Ordem_rel)
BEGIN
    SELECT TOP 1
        @id                          = cd_controle,
        @html_geral = @html_geral +
          '<tr class="tamanho">
		      <td>' + ISNULL(dt_entrega, '') + '</td>
              <td>' + cast(ISNULL(cd_ordem_servico, '') as nvarchar(20))+ '</td>
			  <td>' + ISNULL(dt_ordem_servico, '') + '</td>
              <td>' + ISNULL(nm_fantasia_cliente, '') + '</td>             
              <td>' + cast(ISNULL(ds_def_enc_ordem_servico, '') as nvarchar(60))+ '</td>
			  <td>' + CAST(ISNULL(dbo.fn_formata_valor(vl_final_ordem_servico), 0) AS NVARCHAR(20)) + '</td> 
			  <td>' + CAST(ISNULL(dbo.fn_formata_valor(vl_desconto), 0) AS NVARCHAR(20)) + '</td>
		  	  <td>' + cast(ISNULL(dbo.fn_formata_valor(pc_taxa_bancaria), 0) as nvarchar(20))+ '</td>
              <td>' + CAST(ISNULL(dbo.fn_formata_valor(pix_dinheiro), 0) AS NVARCHAR(20)) + '</td>
			  <td>' + CAST(ISNULL(dbo.fn_formata_valor(vl_custo_financeiro), 0) AS NVARCHAR(20)) + '</td>
			  <td>' + ISNULL(nm_fantasia_fornecedor, '') + '</td> 
              <td>' + ISNULL(dt_compra, '') + '</td>
			  <td>' + CAST(ISNULL(dbo.fn_formata_valor(vl_liquido), 0) AS NVARCHAR(20)) + '</td>
			  <td>' + CAST(ISNULL(vl_margemRel, 0) AS NVARCHAR(20)) + '</td>
			  <td>' + ISNULL(nm_forma_pagamento, '') + '</td>         
			  <td>' + cast(ISNULL(qt_dia_garantia, '180')as nvarchar(20)) + '</td>   
			  <td>' + ISNULL(garantia, '') + '</td>
          </tr>'
	    
    FROM #Entrada_saida_Ordem_rel

    DELETE FROM #Entrada_saida_Ordem_rel WHERE cd_controle = @id
END 
--------------------------------------------------------------------------------------------------------------------




set @html_rodape =
    '	<tr class="letra">
	          <td>Total</td>
              <td></td>
              <td></td>
			  <td>' + cast(ISNULL(@vl_cliente, '') as nvarchar(60))+ '</td>
			  <td></td>
			  <td>' + CAST(ISNULL(dbo.fn_formata_valor(@vl_final_ordem_servico_total), 0) AS NVARCHAR(20)) + '</td>             
			  <td>' + CAST(ISNULL(dbo.fn_formata_valor(@vl_desconto), 0) AS NVARCHAR(20)) + '</td>
		  	  <td>' + cast(ISNULL(dbo.fn_formata_valor(@pc_taxa_bancaria_total), 0) as nvarchar(20))+ '</td>
              <td>' + CAST(ISNULL(dbo.fn_formata_valor(@pix_dinheiro), 0) AS NVARCHAR(20)) + '</td>
			  <td>' + CAST(ISNULL(dbo.fn_formata_valor(@vl_custo_financeiro_total), 0) AS NVARCHAR(20)) + '</td>
			  <td></td> 
              <td></td>
			  <td>' + CAST(ISNULL(dbo.fn_formata_valor(@vl_liquido), 0) AS NVARCHAR(20)) + '</td>
			  <td>' + CAST(ISNULL(dbo.fn_formata_valor(@vl_margem), 0) AS NVARCHAR(20)) + '</td>
			  <td></td>
              <td></td>           
          </tr>
		 </table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
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
--exec pr_relatorio_entrada_saida_ordem_servico 304,0,''
------------------------------------------------------------------------------
