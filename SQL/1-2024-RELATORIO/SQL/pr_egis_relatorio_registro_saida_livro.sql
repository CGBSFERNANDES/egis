IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_registro_saida_livro' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_registro_saida_livro

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_registro_saida_livro
--use egissql_297
-------------------------------------------------------------------------------
--pr_egis_relatorio_registro_saida_livro
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
-- use egissql_360
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_registro_saida_livro
@cd_relatorio int = 0,
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
declare @cd_vendedor            int = 0 
declare @cd_grupo_relatorio     int = 0
declare @cd_parametro           int = 0
declare @cd_tipo_pagamento      int = 0
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
			--@numero					    int = 0,
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
       
--set @cd_parametro      = 0
set @cd_empresa        = 0
set @cd_form           = 0


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
  select @cd_parametro           = valor from #json where campo = 'cd_parametro'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'

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
  @titulo             = nm_relatorio,  
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),  
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)  
from  
  egisadmin.dbo.Relatorio  
where  
  cd_relatorio = @cd_relatorio  
 
 
----------------------------------------------------------------------------------------------------------------------------
select  
  @dt_inicial        = dt_inicial,  
  @dt_final          = dt_final
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


set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)


----------------------------------------------------------------------------------------------------------------------

SET @html_empresa = '
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title >'+@titulo+'</title>
  <style>
    table {
      width: 100%;
      border-collapse: collapse;
      font-family: Arial, sans-serif;
      font-size: 12px;
    }

    th,
    td {
      border: 1px solid #000;
      text-align: center;
      vertical-align: middle;
      padding: 6px;
    }

    .grupo {
      font-weight: bold;
    }

    .sub {
      font-size: 11px;
    }

    .section-title {
      background-color: #1976D2;
      color: white;
      padding: 5px;
      margin-bottom: 10px;
      border-radius: 5px;
      font-size: 120%;
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


--Procedure de Cada Relat�rio-------------------------------------------------------------------------------------
  
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

 --set  @dt_inicial = '12/01/2025'                    -- Data inicial do filtro  
 --set  @dt_final   = '12/30/2025'                     -- Data final do filtro 
 --use egissql_371
------------------------------------------------------------------------------------------------------------
  
CREATE TABLE #Livro_Fiscal_Saida_Rel(

    cd_controle     INT,
    Codigo          INT,
    Especie         VARCHAR(10),
    Serie           VARCHAR(10),
    Numero          INT,
    NumeroInicial   INT,
    NumeroFinal     INT,
    Data            DATETIME,
    Dia             INT,
    UF              CHAR(2),
    VlrContabil     DECIMAL(18,2),
    CodContabil     INT,
    CFOP            VARCHAR(10),
    AliqICMS        DECIMAL(10,2),
    BCICMS          DECIMAL(18,2),
    ICMS            DECIMAL(18,2),
    ICMSIsento      DECIMAL(18,2),
    ICMSOutras      DECIMAL(18,2),
    ICMSObs         DECIMAL(18,2),
    BCICMSST        DECIMAL(18,2),
    ICMSST          DECIMAL(18,2),
    AliqIPI         DECIMAL(10,2),
    BCIPI           DECIMAL(18,2),
    IPI             DECIMAL(18,2),
    IPIIsento       DECIMAL(18,2),
    IPIOutras       DECIMAL(18,2),
    IPIObs          DECIMAL(18,2),
    Observacoes     VARCHAR(255),
    DifICMS         DECIMAL(18,2),
    DifIPI          DECIMAL(18,2)
	)
	insert into 
		#Livro_Fiscal_Saida_Rel
	exec pr_livro_registro_saida 3,3, @dt_inicial,@dt_final,0,@cd_empresa

------------------------------------------------------------------------------------------------------------
set @html_geral = '
		 <table>
    <tr>
      <th class="grupo" colspan="5">Documentos Fiscais</th>
      <th class="grupo" rowspan="3">Valor<br>Contábil</th>
      <th class="grupo" colspan="2">Codificação</th>
      <th class="grupo" colspan="6">Valores Fiscais</th>
      <th class="grupo" rowspan="3">Observações</th>
    </tr>
    <tr>
      <th rowspan="2">Espécie</th>
      <th rowspan="2">Série <br> Sub- Série</th>
      <th rowspan="2">Número</th>
      <th rowspan="2">Dia</th>
      <th rowspan="2">UF</th>
      <th rowspan="2">Contábil</th>
      <th rowspan="2">Fiscal</th>
      <th rowspan="1" style="border:none;">ICMS<br>IPI</th>
      <th colspan="3">Op. com Débito do Imposto</th>
      <th colspan="2">Op. s/ Débito do Imposto</th>
    </tr>
    <tr>
      <th style="border:none;"></th>
      <th>Base de<br>Cálculo</th>
      <th>Alíq.</th>
      <th>Imposto<br>Devido</th>
      <th>Isentas ou não<br>Tributadas</th>
      <th>Outras</th>
    </tr>
	'
	SELECT 
    @html_geral = @html_geral +
    (
        SELECT
    '    <tr>
      <td>'+isnull(Especie,'')+'</td>
      <td>'+cast(isnull(Serie,0)as varchar(20))+'</td>
      <td>'+cast(isnull(Numero,0)as varchar(20))+'</td>
      <td>'+cast(isnull(Dia,0)as varchar(20))+'</td>
      <td>'+isnull(UF,'')+'</td>
      <td>'+cast(isnull(dbo.fn_formata_valor(VlrContabil),0)as varchar(20))+'</td>
      <td>'+cast(isnull(CodContabil,0)as varchar(20))+'</td>
      <td>'+isnull(CFOP,'')+'</td>
      <td>ICMS<br>IPI</td>
      <td>'+cast(isnull(dbo.fn_formata_valor(BCICMS),0)as varchar(20))+' <br> '+cast(isnull(dbo.fn_formata_valor(BCIPI),0)as varchar(20))+'</td>
      <td>'+cast(isnull(dbo.fn_formata_valor(AliqICMS),0)as varchar(20))+' <br> '+cast(isnull(dbo.fn_formata_valor(AliqIPI),0)as varchar(20))+'</td>
      <td>'+cast(isnull(dbo.fn_formata_valor(ICMS),0)as varchar(20))+' <br> '+cast(isnull(dbo.fn_formata_valor(IPI),0)as varchar(20))+'</td>
      <td>'+cast(isnull(dbo.fn_formata_valor(IPIIsento),0)as varchar(20))+' <br> '+cast(isnull(dbo.fn_formata_valor(IPIIsento),0)as varchar(20))+'</td>
      <td>'+cast(isnull(dbo.fn_formata_valor(IPIOutras),0)as varchar(20))+' <br> '+cast(isnull(dbo.fn_formata_valor(IPIOutras),0)as varchar(20))+'</td>
      <td>'+isnull(Observacoes,'')+'</td>
    </tr>'
        FROM #Livro_Fiscal_Saida_Rel
        ORDER BY cd_controle
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)')

set @html_rodape = @html_rodape + '
  </table>
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
  

-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_egis_relatorio_registro_saida_livro 400,'[{"cd_usuario":1,"cd_empresa":297,"cd_relatorio":390,"dt_inicial":"11-01-2025","dt_final":"11-30-2025","cd_tipo_pagamento":4}]'
------------------------------------------------------------------------------
