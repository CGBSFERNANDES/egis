IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_registro_entrada_livro' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_registro_entrada_livro

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_registro_entrada_livro
-------------------------------------------------------------------------------
--pr_egis_relatorio_registro_entrada_livro
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
-- use egissql_360
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_registro_entrada_livro
@cd_relatorio int   = 0, 
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')
declare @data_grafico_bar       nvarchar(max)
declare @cd_empresa             int = 0
declare @cd_parametro           int   = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
declare @cd_documento           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @ic_valor_comercial     varchar(10)
declare @cd_tipo_destinatario   int 
declare @cd_grupo_relatorio     int 
declare @id                     int = 0 
declare @cd_vendedor            int
declare @cd_plano_financeiro    int = 0

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
  
  @dt_inicial    = isnull(dt_inicial,''),
  @dt_final      = isnull(dt_final,'')
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
	  font-family: Arial, Helvetica, sans-serif;
	  background: #fff;
	}
	
	.tabela-fiscal {
	  width: 100%;
	  border-collapse: collapse;
	  table-layout: fixed;
	  font-size: 12px;
	}
	
	.tabela-fiscal th,
	.tabela-fiscal td {
	  border: 1px solid #000;
	  padding: 4px;
	  text-align: center;
	  vertical-align: middle;
	}
	
	
	.tabela-fiscal thead th {
	  font-weight: bold;
	}
	
	
	.tabela-fiscal th:nth-child(1),
	.tabela-fiscal td:nth-child(1) {
	  width: 90px;
	}
	
	.tabela-fiscal th:nth-child(8),
	.tabela-fiscal td:nth-child(8) {
	  width: 100px;
	}
	
	.tabela-fiscal th:last-child,
	.tabela-fiscal td:last-child {
	  width: 180px;
	}
	</style>
</head>
<body>
   
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:30%; margin-right:20px">
			<img src="'+@logo+'" alt="Logo da Empresa">
		</div>
		<div style="width:50%; padding-left:10px">
			<p class="title">'+@nm_fantasia_empresa+'</p>
		    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
		    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
		    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
		</div>  
		<div>
		    <p style="text-align: center;"><strong>(*) Código de Valores Fiscais</strong></p>
		    <Hr></Hr>
		    <p><strong>1 - Operação com Crédito do Imposto</strong></p>
		    <p><strong>2 - Oper.Sem Crédito do Imposto - Isenta ou não tributadas</strong></p>  
		    <p><strong>3 - Oper.Sem Crédito do Imposto - Outras</strong></p>
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
  
order by  
  qt_ordem_atributo  
  
------------------------------------------------------------------------------------------------------------------  

  
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

  
drop table #AuxRelAtributo  
  
  
if isnull(@cd_parametro,0) = 2  
 begin  
  select * from #RelAtributo  
  return  
end  
  

set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
--set @dt_inicial = '10/09/2025'
--set @dt_final = '10/30/2025'

--------------------------------------------------------------------------------------------------------------------------
DECLARE
    @cd_controle        INT,
    @Chave              VARCHAR(50),
    @Entrada            DATETIME,
    @Especie            VARCHAR(10),
    @SubSerie           VARCHAR(10),
    @Numero             INT,
    @Data               DATETIME,
    @Emitente           INT,
    @RazaoSocial        VARCHAR(200),
    @UF                 CHAR(2),
    @VlrContabil        DECIMAL(18,2),
    @ClassContabil      INT,
    @ClassFiscal        VARCHAR(20),
    @CodOperICMS        INT,
    @BCICMS             DECIMAL(18,2),
    @AliqICMS           DECIMAL(10,2),
    @ICMS               DECIMAL(18,2),
    @CodOperIPI         INT,
    @BCIPI              DECIMAL(18,2),
    @IPI                DECIMAL(18,2),
    @ObservacaoICMS     VARCHAR(255),
    @ICMSObs            VARCHAR(255),
    @ObservacaoIPI      VARCHAR(255),
    @IPIObs             VARCHAR(255),
    @REM                INT

CREATE TABLE #Livro_Fiscal_Entrada_Rel(
	cd_controle    INT, 
	Chave          VARCHAR(150),
	Entrada        DATETIME,
	Especie        VARCHAR(10),
	SubSerie       VARCHAR(10),
	Numero         INT,
	Data           DATETIME,
	Emitente       INT,
	RazaoSocial    VARCHAR(200),
	UF             CHAR(2),
	VlrContabil    DECIMAL(18,2),
	ClassContabil  INT,
	ClassFiscal    VARCHAR(20),
	CodOperICMS    INT,
	BCICMS         DECIMAL(18,2),
	AliqICMS       DECIMAL(10,2),
	ICMS           DECIMAL(18,2),
	CodOperIPI     INT,
	BCIPI          DECIMAL(18,2),
	IPI            DECIMAL(18,2),
	ObservacaoICMS VARCHAR(255),
	ICMSObs        VARCHAR(255),
	ObservacaoIPI  VARCHAR(255),
	IPIObs         VARCHAR(255),
	REM            INT
	)
	insert into 
		#Livro_Fiscal_Entrada_Rel
	exec pr_livro_registro_entrada 1, @dt_inicial,@dt_final
-------------------------------------------------------------------------------------------------------------	 
	--select * from #Livro_Fiscal_Entrada_Rel return
	declare 
		@VlrContabil_total float  = 0,
		@BCICMS_1		   float  = 0,
		@Imposto_cred_icms float  = 0,
		@Imposto_cred_ipi  float  = 0,
		@BCIPI_1           FLOAT  = 0,
		@BCIPI_2           FLOAT  = 0,
		@BCIPI_3           FLOAT  = 0,
		@BCICMS_2		   float  = 0,
		@BCICMS_3		   float  = 0
-------------------------------------------------------------------------------------------------------------
select 
	@VlrContabil_total = SUM(VlrContabil),
	@Imposto_cred_icms = sum(ICMS),
	@Imposto_cred_ipi  = SUM(IPI)
from 
	#Livro_Fiscal_Entrada_Rel
-------------------------------------------------------------------------------------------------------------
select 
	@BCICMS_1 = SUM(BCICMS)
from 
	#Livro_Fiscal_Entrada_Rel
where 
	CodOperIcms = 1

select 
	@BCIPI_1 = SUM(BCIPI)
from 
	#Livro_Fiscal_Entrada_Rel
where 
	CodOperIPI = 1
-------------------------------------------------------------------------------------------------------------
select 
	@BCICMS_2 = SUM(BCICMS)
from 
	#Livro_Fiscal_Entrada_Rel
where 
	CodOperIcms = 2

select 
	@BCIPI_2 = SUM(BCIPI)
from 
	#Livro_Fiscal_Entrada_Rel
where 
	CodOperIPI = 2
-------------------------------------------------------------------------------------------------------------
select 
	@BCICMS_3 = SUM(BCICMS)
from 
	#Livro_Fiscal_Entrada_Rel
where 
	CodOperIcms = 3

select 
	@BCIPI_3 = SUM(BCIPI)
from 
	#Livro_Fiscal_Entrada_Rel
where 
	CodOperIPI = 3
--------------------------------------------------------------------------------------------------------------
set @html_geral = '<table class="tabela-fiscal">
    <thead>

      <tr>
        <th rowspan="3">Data de<br>Entrada</th>

        <th colspan="6">Documentos Fiscais</th>

        <th rowspan="3">Valor<br>Contábil</th>

        <th colspan="2">Codificação</th>

        <th colspan="4">ICMS Valores Fiscais</th>

        <th colspan="3">IPI Valores Fiscais</th>

        <th rowspan="3">Observações</th>
      </tr>

      <tr>
        <th rowspan="2">Espécie</th>
        <th rowspan="2">Série /<br>Sub-série</th>
        <th rowspan="2">Nº</th>
        <th rowspan="2">Data do<br>Doc.</th>
        <th rowspan="2">Código<br>Emitente</th>
        <th rowspan="2">UF</th>

        <th rowspan="2">Contábil</th>
        <th rowspan="2">Fiscal</th>
        <th rowspan="2">COD (*)</th>
        <th rowspan="2">Base de Calc.<br>ou Valor da Operação</th>
        <th rowspan="2">Aliq.</th>
        <th rowspan="2">Imposto<br>Creditado</th>
        <th rowspan="2">COD (*)</th>
        <th rowspan="2">Base de Calc.<br>ou Valor da Operação</th>
        <th rowspan="2">Imposto<br>Creditado</th>
      </tr>
      <tr></tr>
	  </thead>
	  <tbody>'

while exists ( select top 1 cd_controle from #Livro_Fiscal_Entrada_Rel)
begin
	select top 1

		@id                          = cd_controle,
	    @html_geral  = @html_geral + '
	   <tr>
        <td>'+isnull(dbo.fn_data_string(Entrada),'')+'</td>
        <td>'+isnull(Especie,'')+'</td>
        <td>'+cast(isnull(SubSerie,0) as varchar(20))+'</td>
        <td>'+cast(isnull(Numero,0) as varchar(20))+'</td>
        <td>'+isnull(dbo.fn_data_string(Data),'')+'</td>
        <td>'+cast(isnull(Emitente,0) as varchar(20))+'</td>
        <td>'+isnull(UF,'')+'</td>

        <td>'+cast(isnull(dbo.fn_formata_valor(VlrContabil),0) as varchar(20))+'</td>

        <td>'+cast(isnull(ClassContabil,0) as varchar(20))+'</td>
        <td>'+isnull(ClassFiscal,'')+'</td>

        <td>'+cast(isnull(CodOperICMS,0) as varchar(20))+'</td>
        <td>'+cast(isnull(BCICMS,0) as varchar(20))+'</td>
        <td>'+cast(isnull(AliqICMS,0) as varchar(20))+'</td>
        <td>'+cast(isnull(ICMS,0) as varchar(20))+'</td>
        <td>'+cast(isnull(CodOperIPI,0) as varchar(20))+'</td>
        <td>'+cast(isnull(BCIPI,0) as varchar(20))+'</td>
        <td>'+cast(isnull(IPI,0) as varchar(20))+'</td>
        <td>'+isnull(RazaoSocial,'')+' - '+cast(isnull(REM,0) as varchar(20))+'</td>
      </tr>'

     from #Livro_Fiscal_Entrada_Rel
	 delete from #Livro_Fiscal_Entrada_Rel where cd_controle = @id
 end
		   
--------------------------------------------------------------------------------------------------------------
set @html_geral  = @html_geral + 
	'</tbody>
	  <tbody>
	  <tr>
        <td colspan="8">
          <table style="width:100%; border-collapse:collapse;">
            <tr>
             <td style="text-align:right; border:none;">Total</td>
             <td style="text-align:right; border:none;">'+CAST(isnull(dbo.fn_formata_valor(@VlrContabil_total),0) as varchar(20))+'</td>
            </tr>
          </table>
        </td>
        
        <td colspan="2"></td>
        <td>1</td>
        <td>'+CAST(isnull(dbo.fn_formata_valor(@BCICMS_1),0) as varchar(20))+'</td> 
        <td colspan="2" style="text-align:right;">'+CAST(isnull(dbo.fn_formata_valor(@Imposto_cred_icms),0) as varchar(20))+'</td>
        <td>1</td>
        <td>'+CAST(isnull(dbo.fn_formata_valor(@BCIPI_1),0) as varchar(20))+'</td>               
        <td colspan="1" style="text-align:right;">'+CAST(isnull(dbo.fn_formata_valor(@Imposto_cred_ipi),0) as varchar(20))+'</td>
        <td></td>
      </tr>
	  </tbody>'
--------------------------------------------------------------------------------------------------------------
set @html_geral  = @html_geral + 
	'</tbody>
	  <tbody>
	  <tr>
        <td colspan="8">
          <table style="width:100%; border-collapse:collapse;">
            <tr>
             <td style="text-align:right; border:none;"></td>
             <td style="text-align:right; border:none;"></td>
            </tr>
          </table>
        </td>
        
        <td colspan="2"></td>
        <td>2</td>
        <td>'+CAST(isnull(dbo.fn_formata_valor(@BCICMS_2),0) as varchar(20))+'</td> 
        <td colspan="2" style="text-align:right;"></td>
        <td>2</td>
        <td>'+CAST(isnull(dbo.fn_formata_valor(@BCIPI_2),0) as varchar(20))+'</td>               
        <td colspan="1" style="text-align:right;"></td>
        <td></td>
      </tr>
	  </tbody>'
--------------------------------------------------------------------------------------------------------------
set @html_geral  = @html_geral + 
	'</tbody>
	  <tbody>
	  <tr>
        <td colspan="8">
          <table style="width:100%; border-collapse:collapse;">
            <tr>
             <td style="text-align:right; border:none;"></td>
             <td style="text-align:right; border:none;"></td>
            </tr>
          </table>
        </td>
        
        <td colspan="2"></td>
        <td>3</td>
        <td>'+CAST(isnull(dbo.fn_formata_valor(@BCICMS_3),0) as varchar(20))+'</td> 
        <td colspan="2" style="text-align:right;"></td>
        <td>3</td>
        <td>'+CAST(isnull(dbo.fn_formata_valor(@BCIPI_3),0) as varchar(20))+'</td>               
        <td colspan="1" style="text-align:right;"></td>
        <td></td>
      </tr>
	  </tbody>'   		   
--------------------------------------------------------------------------------------------------------------

set @html_rodape =
    '</table>
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
-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
exec pr_egis_relatorio_registro_entrada_livro 374,''
------------------------------------------------------------------------------

