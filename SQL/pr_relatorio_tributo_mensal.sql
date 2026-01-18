IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_tributo_mensal' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_tributo_mensal

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_tributo_mensal
-------------------------------------------------------------------------------
--pr_relatorio_tributo_mensal
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
create procedure pr_relatorio_tributo_mensal
@cd_relatorio int   = 0,
@cd_parametro int   = 0, 
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

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
declare @cd_vendedor            int
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
--set @cd_parametro      = 0
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
--------------------------------------------------------------------------------------------------------------------------
   select  
  
  @dt_inicial      = isnull(dt_inicial ,0),
  @dt_final      = isnull(dt_final ,0)
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
            padding: 10px;
        }

        td {
            text-align: center;
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
--set @dt_inicial = '01/01/2025'
--set @dt_final = '01/31/2025'
--------------------------------------------------------------------------------------------------------------------------
declare @vl_ipi_apuracao          decimal(25,4) 
declare @vl_icms_apuracao         decimal(25,4)
declare @qt_cobranca              decimal(25,4)          
declare @vl_cobranca              decimal(25,4)          
declare @qt_cobranca_aberto       decimal(25,4)          
declare @vl_cobranca_aberto       decimal(25,2)          
declare @qt_carteira_aberto       decimal(25,4)          
declare @vl_carteira_aberto       decimal(25,2)          
declare @qt_proposta              decimal(25,4)          
declare @vl_proposta              decimal(25,2)          
declare @qt_carteira              decimal(25,4)          
declare @vl_carteira              decimal(25,2)          
declare @vl_base_faturamento      decimal(25,2)
declare @vl_base_faturamento_p    decimal(25,2)
declare @vl_base_faturamento_s    decimal(25,2) = 0.00
declare @vl_base_faturamento_nf   decimal(25,2) = 0.00         
declare @vl_base_faturamento_vv   decimal(25,2) = 0.00         
declare @vl_base_faturamento_prod decimal(25,2)          
declare @vl_base_faturamento_serv decimal(25,2) = 0.00          
declare @vl_frete                 decimal(25,2) = 0.00
declare @vl_icms                  decimal(25,2)          
declare @vl_ipi                   decimal(25,2)          
declare @vl_imposto_recolher      decimal(25,2)          
declare @vl_pis                   decimal(25,2)          
declare @vl_cofins                decimal(25,2) = 0.00          
declare @vl_csll                  decimal(25,2)          
declare @qt_recebimento           decimal(25,4)          
declare @vl_recebimento           decimal(25,2)          
declare @vl_recebimento_servico   decimal(25,2) = 0.00
declare @cd_unidade_medida        int          
declare @cd_serie_nota_cupom      int          
declare @qt_compra                float = 0.00          
declare @vl_compra                float          
declare @vl_total_VD              float          
declare @qt_total_VD              float          
declare @qt_total_CP              float          
declare @vl_total_CP              float           
declare @vl_vd                    float          
declare @vl_cp                    float          
declare @vl_DF                    float          
declare @vl_total_DF              float          
declare @vl_bruto                 float          
declare @vl_delta                 float          
declare @cd_controle              int          
declare @vl_bc_icms               float          
declare @peso_liquido             float          
declare @peso_liquido_servico     float
declare @peso_liquido_total       float
declare @total_nota               float        
declare @vl_icms_entrada          float      
declare @vl_icms_entrada_dev      float      
declare @vl_cofins_entrada        float      
declare @vl_pis_entrada           float      
declare @vl_ipi_entrada           float
declare @vl_ipi_entrada_dev       float
declare @vl_pis_entrada_dev       float
declare @vl_cof_entrada_dev       float
declare @vl_devolucao_entrada_p   float      
declare @vl_devolucao_entrada_nf  float      
declare @vl_devolucao_icms        float
declare @peso_devolucao           float
declare @peso_servico             float
declare @vl_icms_dev_for          float
declare @vl_cofins_dev_for        float      
declare @vl_pis_dev_for           float      
declare @vl_ipi_dev_for           float
declare @vl_dev_for_p             float      
declare @vl_dev_for_nf            float      
declare @peso_dev_for             float
declare @vl_csll_imp              float
declare @pc_cofins_imp            float
declare @pc_pis_imp               float
declare @pc_lucro_imp             float
declare @vl_lucro_imp             float
declare @vl_pis_imp               float
declare @vl_entrada               float
declare @pc_csll_imp              float
declare @vl_unitario_servico      decimal(25,2)
declare @vl_entrada_serv		  decimal(25,2)
declare @vl_peso_serv_rec		  decimal(25,2)
declare @vl_devolucao    		  decimal(25,2)
declare @qt_peso_devolucao		  decimal(25,2)



CREATE TABLE #teste (
  qt_cobranca                decimal(25,4),
  vl_cobranca                decimal(25,4),
  qt_peso_venda              decimal(25,4),
  vl_total_venda             decimal(25,2),
  qt_total_VD                float,
  vl_total_VD                float,
  qt_compra                  float,
  vl_compra                  float,
  VD                         float,
  CP                         float,
  DF                         float,
  Resultado                  float,
  Bruto                      float,
  Delta                      float,
  Base_Calculo               decimal(25,2),
  Base_Calculo_Servico       decimal(25,2),
  ICMS_ENTRADA               float,
  ICMS                       decimal(25,2),
  ICMS_APURACAO              float,
  IPI_ENTRADA                float,
  IPI                        decimal(25,2),
  IPI_APURACAO               float,
  Imposto_recolher           decimal(25,2),
  pc_cofins_imp              float,
  vl_cofins_imp              decimal(25,2),
  pc_pis_imp                 float,
  vl_pis_imp                 decimal(25,2),
  pc_csll_imp                float,
  vl_csll_imp                decimal(25,2),
  pc_lucro_imp               float,
  vl_lucro_imp               decimal(25,2),
  Base_ICMS                  float,
  Total_Nota                 decimal(25,2),
  Peso_Liquido_Total         float,
  Peso_liquido               float,
  Peso_liquido_Servico       float,
  Unitario_Servico           decimal(25,2),
  vl_frete                   decimal(25,2),
  qt_entrada                 decimal(25,4),
  vl_entrada                 decimal(25,2),
  vl_entrada_servico         decimal(25,2),
  Peso_Entrada_Servico       float,
  Total_Produto              decimal(25,2),
  Valor_Devolucao            decimal(25,2),
  Peso_Devolucao             float,
  Valor_Dev_IPI_Entrada      decimal(25,2),
  Base_Calculo_Csll_Lucro    decimal(25,2),
  Base_VV                    decimal(25,2)
  )
  INSERT INTO #teste
  exec pr_demonstrativo_periodo_operacional 0,1,@dt_inicial,@dt_final
 --drop table #teste

 select 
	@vl_base_faturamento_p = Base_Calculo,
	@vl_base_faturamento = Total_Nota,
	@vl_bruto = Bruto,
	@vl_compra = vl_compra,
	@peso_liquido = Peso_liquido,
	@peso_liquido_servico = Peso_liquido_Servico,
	@vl_base_faturamento_s = Base_Calculo_Servico,
	@peso_liquido_total = Peso_Liquido_Total,
	@vl_icms = ICMS,
	@vl_icms_entrada = ICMS_ENTRADA,
	@vl_ipi = IPI,
	@vl_ipi_entrada = IPI_ENTRADA,
	@vl_csll_imp = vl_csll_imp,
	@vl_cofins = vl_cofins_imp,
	@vl_pis_imp = vl_pis_imp,
	@vl_vd = VD,
	@vl_CP = CP,
	@vl_DF =DF,
	@vl_delta = Delta,
	@vl_imposto_recolher = Imposto_recolher,
	@pc_csll_imp = pc_csll_imp,
	@pc_cofins_imp = pc_cofins_imp,
	@pc_pis_imp = pc_pis_imp,
	@pc_lucro_imp = pc_lucro_imp,
	@vl_lucro_imp = vl_lucro_imp,
	@qt_recebimento = qt_entrada,
	@vl_entrada = vl_entrada,
	@vl_total_DF = Resultado,
	@vl_unitario_servico = Unitario_Servico,
	@vl_ipi_apuracao = IPI_APURACAO,
	@vl_icms_apuracao = ICMS_APURACAO,
	@vl_entrada_serv = vl_entrada_servico,
	@vl_peso_serv_rec = peso_entrada_servico,
	@vl_devolucao = Valor_devolucao,   	
	@qt_peso_devolucao	= peso_devolucao,
	@vl_frete = vl_frete       	
 from #teste

--------------------------------------------------------------------------------------------------------------
set @html_geral = '<div>
		<p class="section-title" style="text-align: center; padding: 8px;">Tributos Mensais - Período de '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p> 
	</div>
                <div style="display: flex; gap: 20px;">

                    <table >
                        <tr><th colspan="2" style="text-align: center;">Informações Gerais</th></tr>
                        <tr><th>Total Produtos</th><td style="text-align: center;">'+cast(isnull(dbo.fn_formata_valor(@vl_base_faturamento_p),0) as nvarchar(20))+'</td></tr>
                        <tr><th>Total Nota</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_base_faturamento),0) as nvarchar(20))+'</td></tr>
                        <tr><th>Bruto</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_bruto),0) as nvarchar(20))+'</td></tr>
						<tr><th>Fornec. Serviços</th><td>'+cast(isnull(dbo.fn_formata_valor(@qt_compra),0) as nvarchar(20))+'</td></tr>
						<tr><th>Valor Compra</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_compra),0) as nvarchar(20))+'</td></tr>
						<tr><th>Peso Produtos</th><td>'+cast(isnull(dbo.fn_formata_valor(@peso_liquido),0) as nvarchar(20))+'</td></tr>
						<tr><th>Peso Serviços</th><td>'+cast(isnull(dbo.fn_formata_valor(@peso_liquido_servico),0) as nvarchar(20))+'</td></tr>
						<tr><th>Entrada Serviços</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_entrada_serv),0) as nvarchar(20))+'</td></tr>
						<tr><th>Peso Serviços Recebimento</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_peso_serv_rec),0) as nvarchar(20))+'</td></tr>
						<tr><th>Valor Devolução</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_devolucao),0) as nvarchar(20))+'</td></tr>
						<tr><th>Peso Devolução</th><td>'+cast(isnull(dbo.fn_formata_valor(@qt_peso_devolucao),0) as nvarchar(20))+'</td></tr>
						<tr><th>Valor Frete</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_frete),0) as nvarchar(20))+'</td></tr>
						<tr><th>Total Serviços</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_base_faturamento_s),0) as nvarchar(20))+'</td></tr>
						<tr><th>Peso Total</th><td>'+cast(isnull(dbo.fn_formata_valor(@peso_liquido_total),0) as nvarchar(20))+'</td></tr>
                    </table>

                    <table >
                        <tr><th colspan="2" style="text-align: center;">Impostos e Tributos</th></tr>
                        <tr><th>ICMS Saída</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_icms),0) as nvarchar(20))+'</td></tr>
                        <tr><th>ICMS Entrada</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_icms_entrada),0) as nvarchar(20))+'</td></tr>
						<tr><th>ICMS Apuração</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_icms_apuracao),0) as nvarchar(20))+'</td></tr>
						<tr><th>Unitário MO</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_unitario_servico),0) as nvarchar(20))+'</td></tr>
                        <tr><th>IPI Saída</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_ipi),0) as nvarchar(20))+'</td></tr>
                        <tr><th>IPI Entrada</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_ipi_entrada),0) as nvarchar(20))+'</td></tr>
						<tr><th>IPI Apuração</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_ipi_apuracao),0) as nvarchar(20))+'</td></tr>
                        <tr><th>CSLL</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_csll_imp),0) as nvarchar(20))+'</td></tr> 
                        <tr><th>COFINS</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_cofins),0) as nvarchar(20))+'</td></tr>
                        <tr><th>PIS</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_pis_imp),0) as nvarchar(20))+'</td></tr>
                    </table>

                    <table >
                        <tr><th colspan="2" style="text-align: center;">Resultados e Indicadores</th></tr>
                        <tr><th>VD</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_vd),0) as nvarchar(20))+'</td></tr>
                        <tr><th>CP</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_CP),0) as nvarchar(20))+'</td></tr>
                        <tr><th>DF</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_DF),0) as nvarchar(20))+'</td></tr>
                        <tr><th>Delta</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_delta),0) as nvarchar(20))+'</td></tr>
                        <tr><th>Imposto a Recolher</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_imposto_recolher),0) as nvarchar(20))+'</td></tr>
                        <tr><th>(%) CSLL</th><td>'+cast(isnull(dbo.fn_formata_valor(@pc_csll_imp),0) as nvarchar(20))+'</td></tr>
                        <tr><th>(%) COFINS</th><td>'+cast(isnull(dbo.fn_formata_valor(@pc_cofins_imp),0) as nvarchar(20))+'</td></tr>
                        <tr><th>(%) PIS</th><td>'+cast(isnull(dbo.fn_formata_valor(@pc_pis_imp),0) as nvarchar(20))+'</td></tr>
                        <tr><th>(%) Lucro Presumido</th><td>'+cast(isnull(dbo.fn_formata_valor(@pc_lucro_imp),0) as nvarchar(20))+'</td></tr>
                        <tr><th>Lucro Presumido</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_lucro_imp),0) as nvarchar(20))+'</td></tr>
                        <tr><th>KG Recebimento</th><td>'+cast(isnull(dbo.fn_formata_valor(@qt_recebimento),0) as nvarchar(20))+'</td></tr>
                        <tr><th>Entrada Produto</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_entrada),0) as nvarchar(20))+'</td></tr>
						<tr><th>Resultado</th><td>'+cast(isnull(dbo.fn_formata_valor(@vl_total_DF),0) as nvarchar(20))+'</td></tr>
                    </table>
                </div>'
					   
--------------------------------------------------------------------------------------------------------------

set @html_rodape =
    '</table>
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
--exec pr_relatorio_tributo_mensal 230,0,'[{
--    "cd_empresa": "275",
--    "cd_modulo": "360",
--    "cd_menu": "0",
--    "cd_relatorio_form": 259,
--    "cd_processo": "",
--    "cd_form": 91,
--    "cd_documento_form": 1,
--    "cd_parametro_form": "2",
--    "cd_usuario": "3572",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "3572",
--    "dt_usuario": "2025-06-12",
--    "lookup_formEspecial": {},
--    "cd_parametro_relatorio": "1",
--    "cd_relatorio": "259",
--    "dt_inicial": "2025-04-01",
--    "dt_final": "2025-04-30",
--    "detalhe": [],
--    "lote": [],
--    "cd_documento": "1"
--}]'
------------------------------------------------------------------------------

