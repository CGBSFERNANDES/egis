IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_tecnico' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_tecnico

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_ordem_servico_saida
-------------------------------------------------------------------------------
--pr_egis_relatorio_ordem_servico_saida
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
create procedure pr_egis_relatorio_tecnico
@cd_relatorio int   = 0,
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')

declare @cd_empresa             int = 0
declare @cd_modulo              int = 0
declare @cd_menu                int = 0
declare @cd_processo            int = 0
declare @cd_item_processo       int = 0
declare @cd_form                int = 0
--declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
declare @cd_item_documento      int = 0
declare @cd_parametro           int = 0
declare @dt_hoje                datetime
--declare @dt_inicial             datetime
--declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @cd_grupo_relatorio     int
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ordem_servico       int = 0
declare @cd_usuario             int  = 0


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
			@cd_cnpj_cliente		    varchar(30) = '',
			@nm_razao_social_cliente	varchar(200) = '',
			@nm_bairro					varchar(200) = '',
			@nm_cidade_cliente			varchar(200) = '',
			@sg_estado_cliente			varchar(5)	= '',
			--@cd_numero_endereco			varchar(20) = '',
			@cd_telefone				varchar(20) = '',
			@nm_condicao_pagamento		varchar(100) = '',
			@ds_relatorio				varchar(8000) = '',
			@subtitulo					varchar(40)   = '',
			@footerTitle				varchar(200)  = '',
			@vl_total_ipi				float         = 0,
			@sg_tabela_preco            char(10)      = '',
			@cd_empresa_faturamento     int           = 0,
			@nm_fantasia_faturamento    varchar(30)   = '',
			@cd_tipo_pedido             int           = 0,
			@nm_tipo_pedido             varchar(30)   = '',
			@cd_vendedor                int           = 0,
			@nm_fantasia_vendedor       varchar(500)   = '',
			@nm_telefone_vendedor       varchar(30)   = '',
			@nm_email_vendedor          varchar(300)  = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = '',
			@nm_status					varchar(100) = '',
			@ic_empresa_faturamento		char(1) = '',
			@tel_empresa                nvarchar(20) =''
					   
--------------------------------------------------------------------------------------------------------

set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
set @cd_parametro      = 0

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
  select @cd_modulo              = valor from #json where campo = 'cd_modulo'             
  select @cd_processo            = valor from #json where campo = 'cd_processo'             
  select @cd_item_processo       = valor from #json where campo = 'cd_item_processo'             
 -- select @cd_usuario           = valor from #json where campo = 'cd_usuario'             
  select @cd_ordem_servico       = valor from #json where campo = 'cd_documento_form'
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'
  select @cd_ordem_servico       = valor from #json where campo = 'cd_ordem_servico'


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'
     select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'

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
declare @nm_bairro_t nvarchar(100)
	--Dados da empresa-----------------------------------------------------------

	select 
		@logo = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),
		@nm_cor_empresa		   	    = isnull(e.nm_cor_empresa,'#1976D2'),
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
		@nm_dominio_internet		=  ltrim(rtrim(isnull(e.nm_dominio_internet,''))),
		@nm_bairro_t                =  isnull(e.nm_bairro_empresa,''),
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
declare @html_grafico    nvarchar(max) = '' --Gráfico
declare @html_titulo     nvarchar(max) = '' --Título
declare @html_cab_det    nvarchar(max) = '' --Cabeçalho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_rod_det    nvarchar(max) = '' --Rodapé do Detalhe
declare @html_rodape     nvarchar(max) = '' --Rodape
declare @html_totais     nvarchar(max) = '' --Totais
declare @html_geral      nvarchar(max) = '' --Geral

declare @titulo_total    varchar(500)  = ''

declare @data_hora_atual nvarchar(50)  = ''

set @html         = ''
set @html_empresa = ''
set @html_grafico = ''
set @html_titulo  = ''
set @html_cab_det = ''
set @html_detalhe = ''
set @html_rod_det = ''
set @html_rodape  = ''

-- Obtém a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------
--Título do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------
--select * from egisadmin.dbo.relatorio


--select @titulo
--

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
            background-color: #f9f9f9;
        }

        .container {
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
            flex:1;
            width: 100%;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom:5px ;
        }

        table,
        th,
        td {
            border: 1px solid black;
        }

        th,
        td {
            padding: 10px;
            text-align: center;
            font-size: 14px;
        }

        th {
            background-color: #f2f2f2;
            color: #333;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        img {
            max-width: 250px;
        }

        .report-date-time {
            text-align: right;
            margin-bottom: 1px;
        }

        .section {
            border: 1px solid black;
            padding: 1px;
            text-align: center;
        }

        .header-table {
            width: 100%;
            border: 1px solid black;
            border-collapse: collapse;
        }

        .bold {
            font-weight: bold;
            font-size: 14px;
        }

        #imprimir {
            background-color: #1976D2;
            color: white;
            border: none;
            padding: 5px 10px;
            font-size: 14px;
            cursor: pointer;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        @media print {
            @media print {
      @page {
         size: A4 landscape;
         margin: 0;
      }

      body {
        display: block !important;
      }
     th, td {
                padding: 24px !important;
              font-size: 13.5px;
            }

      .container {
        width: 100% !important;
        display: block !important;
      }

      * {
        -webkit-print-color-adjust: exact;
        print-color-adjust: exact;
      }

      #imprimir {
        display: none;
      }
    }

    </style>
	</head>
'

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


select

  @cd_vendedor    = isnull(cd_vendedor,0),
  @cd_cliente     = isnull(cd_cliente,0),
  @cd_tipo_pedido = 0 
from 
  Parametro_Relatorio

where
  cd_relatorio = @cd_relatorio
  and
  cd_usuario   = @cd_usuario

---> CCF <----
---> alteração com o processo do relatório


declare @id int = 0

declare @qt_dia_garantia int = 0  
select  
  @qt_dia_garantia = isnull(qt_dia_garantia,0)  
from config_ordem_servico  
where  
  cd_empresa = @cd_empresa  
  
--------------------------------------------------------------------------------------------------
  
select  
  l.dt_finalizada_ordem_servico,  
  case when l.dt_vencimento_garantia is null then  
    l.dt_finalizada_ordem_servico + isnull(@qt_dia_garantia,180)   
  else  
    l.dt_vencimento_garantia  
  end                                           as dt_vencimento_garantia,  
  l.dt_liberacao_ordem                          as dt_liberacao_ordem,  
  l.vl_analise_ordem_servico                    as vl_analise_ordem_servico,
  l.dt_analise                                  as dt_analise,
  os.cd_ordem_servico                           as cd_ordem_servico,  
  l.dt_liberacao_tecnica                        as dt_liberacao_tecnica,
  l.ds_analise_tecnica                          as ds_analise_tecnica, 
  l.ds_componentes                              as ds_componentes,    
  os.dt_ordem_servico,  
  os.cd_cliente,  
  os.cd_tecnico,  
  os.ds_def_enc_ordem_servico,  
  os.cd_marca_produto,  
  os.hr_entrada_registro,  
  os.nm_modelo_produto                          as nm_modelo_produto,  
  os.ds_aspecto,  
  os.cd_numero_serie                            as cd_numero_serie,
  isnull(os.vl_total_ordem_servico,0)           as vl_total_ordem_servico,  
  
  --Cliente--  
  c.nm_fantasia_cliente,  
  c.nm_razao_social_cliente,  
  
  --Contato--  
  case when isnull(os.cd_contato,0)>0 then  
    cc.nm_contato_cliente  
  else  
    os.nm_contato_ap_ordem_serv  
  end as nm_contato_cliente,  
    
  --Técnico  
  t.nm_tecnico,  
  
  --Status  
  sos.nm_status_ordem_servico                   as nm_status_ordem_servico,  
  
  --Defeito--  
  td.nm_tipo_defeito,  
  
  --Marca--  
  mp.nm_marca_produto                     as nm_marca_produto,  
  
  --Prioridade  
  
  tp.nm_tipo_prioridade,  
  
  --Usuário  
  u.nm_fantasia_usuario  
  

into  
  #OrdemServicoGarantiaRel  
  
from  
  Ordem_Servico os  
  left outer join Ordem_Servico_Laboratorio l   on l.cd_ordem_servico          = os.cd_ordem_servico  
  inner join cliente c                     on c.cd_cliente                = os.cd_cliente  
  left outer join cliente_contato cc       on cc.cd_cliente               = os.cd_cliente and  
                                              cc.cd_contato               = os.cd_contato  
  
  left outer join marca_produto mp         on mp.cd_marca_produto         = os.cd_marca_produto  
  left outer join tecnico t                on t.cd_tecnico                = os.cd_tecnico  
  left outer join tipo_defeito td          on td.cd_tipo_defeito          = os.cd_tipo_defeito_cliente  
  left outer join status_ordem_servico sos on sos.cd_status_ordem_servico = os.cd_status_ordem_servico  
  left outer join egisadmin.dbo.usuario u  on u.cd_usuario                = os.cd_usuario  
  left outer join tipo_prioridade tp       on tp.cd_tipo_prioridade       = os.cd_tipo_prioridade  
  
  --select * from ordem_servico_laboratorio  
  
    
--where  
-- l.dt_finalizada_ordem_servico between @dt_inicial and @dt_final  

where
  os.cd_ordem_servico = @cd_ordem_servico  --9

 ------------------------------------------------------------------------------------------------------ 
 declare @ds_mesagem   nvarchar(500)
 declare @ds_cabecalho nvarchar(500)

 select top 1 
		@ds_mesagem   = ds_garantia, 
		@ds_cabecalho = ds_mensagem_cab_ordem
 from config_ordem_servico

 --------------------------------------------------------------------------------------------------------
declare @dt_ordem_servico                    datetime = 0
declare @nm_modelo_produto                   nvarchar(60)	
declare @nm_marca_produto                    nvarchar(60)
declare @nm_aspecto_produto                  nvarchar(100)
declare @ds_def_enc_ordem_servico            nvarchar(100)
declare @nm_fantasia_cliente                 nvarchar(60)
declare @nm_endereco_cliente                 nvarchar(60)
declare @nm_contato_cliente                  nvarchar(60)
declare @nm_cidade_cli                       nvarchar(60)
declare @sg_estado_cli                       nvarchar(60)
declare @nm_bairro_cli                       nvarchar(60)
declare @cd_numero_endereco                  nvarchar(15)
declare @cd_numero_serie                     nvarchar(15)
declare @nm_status_ordem_servico             nvarchar(30)
declare @vl_analise_ordem_servico            float = 0 
declare @dt_analise                          datetime
declare @dt_liberacao_tecnica                datetime
declare @ds_analise_tecnica                  nvarchar(500)
declare @ds_componentes                      nvarchar(200)
declare @dt_liberacao_ordem                  datetime
declare @dt_vencimento_garantia              datetime
select
	@dt_ordem_servico                    = dt_ordem_servico, 
    @nm_modelo_produto                   = nm_modelo_produto,	
	@nm_marca_produto                    = nm_marca_produto,
    @nm_aspecto_produto                  = ds_aspecto,
    @ds_def_enc_ordem_servico            = nm_tipo_defeito,
    @nm_fantasia_cliente                 = nm_fantasia_cliente,
	@cd_numero_serie                     = cd_numero_serie,
	@vl_analise_ordem_servico            = vl_analise_ordem_servico,
	@dt_analise                          = dt_analise,
	@dt_liberacao_tecnica                = dt_liberacao_tecnica,
	@ds_analise_tecnica                  = ds_analise_tecnica,
	@ds_componentes                      = ds_componentes,
	@dt_liberacao_ordem                  = dt_liberacao_ordem,
	@dt_vencimento_garantia               = dt_vencimento_garantia

from #OrdemServicoGarantiaRel
--select @nm_fantasia_cliente
 --------------------------------------------------------------------------------------------------------

set @html_cab_det ='<body>
     <div class="container">
        <table class="header-table">
            <tr>
                <td rowspan="5" >
                    <img src="'+isnull(@logo,'')+'" alt="Logo da Empresa">
                </td>
                <td colspan="4" class="bold">'+isnull(@nm_fantasia_empresa,'')+'</td>
				<td>RELATÓRIO TÉCNICO</td>
            </tr>
            <tr class="bold">
                
                <td colspan="4" class="header-info"> RELATÓRIO TÉCNICO</td>
                <td colspan="2">OS Nº: '+cast(isnull(@cd_ordem_servico,'')as nvarchar(15))+'</td>
            </tr>
            <tr class="bold">
                <td style="text-align: left;">CNPJ: '+isnull(@cd_cnpj_empresa,'')+'</td>
                <td >'+isnull(@nm_endereco_empresa,'')+', '+cast(isnull(@cd_numero_endereco_empresa,0)as nvarchar(15))+' - '+isnull(@nm_bairro_t,'')+' - '+isnull(@nm_cidade,'')+' - '+isnull(@sg_estado,'')+'</td>
                <td > TEL: '+isnull(@cd_telefone_empresa,'')+' - '+isnull(@tel_empresa,'')+' </td>
				<td >I.E: '+isnull(@cd_inscestadual_empresa,'')+'</td>
				<td >'+isnull(dbo.fn_data_string(@dt_ordem_servico),'')+'</td> 
            </tr>
        </table> 
		<table>
        <tr>
		    <th>MARCA</th>
            <th>MODELO</th>
            <th>SÉRIE</th>
            <th>VALOR PREVISTO</th>
            <th>STATUS</th>
            <th>DATA</th>
        </tr>
		
        <tr>
            <td>'+isnull(@nm_marca_produto,'')+'</td>
            <td>'+isnull(@nm_modelo_produto,'')+'</td>
            <td>'+isnull(@cd_numero_serie,'')+'</td>
			<td>'+CAST(isnull(dbo.fn_formata_valor(@vl_analise_ordem_servico),0) as nvarchar(20))+'</td>
            <td>'+isnull(@nm_status_ordem_servico,'')+'</td>
			<td>'+isnull(dbo.fn_data_string(@dt_analise),'')+'</td>
        </tr>
       </table>   
        <div style="display: flex; justify-content: space-between;width: 100%;"">
		'+ case when isnull(@ds_analise_tecnica,'') <> '' then '
        <table style="text-align: left;width: 50%;">
            <tr style="text-align: center;">
                <th>AVALIAÇÃO TÉCNICA VERIFICADA</th>
            </tr>
            <tr style="text-align: center;">
                <td>'+isnull(@ds_analise_tecnica,'')+'</td>
            </tr>
        </table>
		'
		else '<h1 style="width: 50%;text-align: center; margin-top: 40px;">Análise Técnica não Realizada</h1>'
		end+'
        <table style="text-align: right;width: 50%;">
            <tr>
                <th>COMPRA DE PEÇAS</th>
            </tr>
            <tr style="text-align: center;">
                <td>'+isnull(dbo.fn_data_string(@dt_liberacao_ordem),'')+'</td>
            </tr>
            <tr>
                <th>LIBERAÇÃO TÉCNICA</th>
            </tr>
            <tr style="text-align: center;">
                <td>'+isnull(dbo.fn_data_string(@dt_liberacao_tecnica),'')+'</td>
            </tr>
        </table>
        </div>
        <table style="width: 100%;">
            <tr >
                <th style="width: 50%;">PEÇAS A SEREM SUBSTITUÍDAS</th>
                <th style="width: 50%;">GARANTIA</th>
            </tr>
            <tr >
                <td style="text-align: CENTER;">'+isnull(@ds_componentes,'')+'</td>
                <td style="text-align: CENTER;">'+ISNULL(@ds_mesagem,'')+'</td>
            </tr>
        </table>'
----------------------------------------------------------------------------------------------------------------------------------



set @footerTitle = ''

--Rodapé--

set @html_rodape =
    '<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
	<div class="report-date-time">
     <button  id="imprimir">Imprimir</button>
        </div>
        
    </div>
      <script>
        document.querySelector("#imprimir").addEventListener("click", function () {
          window.print();
        });
      </script>
</body>

</html>'


--Gráfico--
set @html_grafico = ''

--HTML Completo--------------------------------------------------------------------------------------

set @html         = 
    @html_empresa +
	@html_titulo  +
	@html_cab_det + 
	@html_detalhe +
	@titulo_total +
	@html_totais  +
	@html_geral   + 
	@html_grafico +
    @html_rodape  



-------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------
go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_egis_relatorio_tecnico 298,''