IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_consulta_cliente_vendedor' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_consulta_cliente_vendedor

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_consulta_cliente_vendedor
-------------------------------------------------------------------------------
--pr_egis_relatorio_consulta_cliente_vendedor
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : João Pedro Marçal
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis
--
--Data             : 10.02.2025
--Alteraçãoo        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_consulta_cliente_vendedor
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
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
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

--------------------------------------------------------------------------------------------------------------------------
--- select cliente
--------------------------------------------------------------------------------------------------------------------------

--Parametro_Relatorio---

declare @cd_tipo_relatorio      int = 0
declare @cd_empresa_faturamento int = 0
declare @cd_metodo              int = 0

----------------------------------------------------------------------------------------------------------------------------
select  
  @dt_inicial             = dt_inicial,  
  @dt_final               = dt_final,
  @cd_vendedor            = cd_vendedor

from   
  Parametro_Relatorio  
  
where  
  cd_relatorio = @cd_relatorio  
  and  
  cd_usuario   = @cd_usuario  
---------------------------------------------------------------------------------------------------------------------------
select
  d.cd_cliente,
  SUM( isnull(vl_documento_receber,0)) as vl_documento_receber
into #Atraso

from
  Documento_Receber d
where
  d.dt_cancelamento_documento is null
  and
  ISNULL(d.vl_saldo_documento,0)>0
  and
  d.dt_emissao_documento < '10/16/2024'

group by 
  d.cd_cliente
 
select 
  identity(int,1,1)                         as cd_controle,
  c.cd_cliente_grupo,
  cg.nm_cliente_grupo,
  c.cd_cliente,
  c.nm_fantasia_cliente,
  c.nm_razao_social_cliente,
  case when c.cd_tipo_pessoa = 1 then --select * from tipo_pessoa
   dbo.fn_formata_cnpj(c.cd_cnpj_cliente)
  else
   dbo.fn_formata_cpf(c.cd_cnpj_cliente)
  end  as cd_cnpj_clientee,
  cid.nm_cidade,
  e.sg_estado,
  c.nm_endereco_cliente,
  c.nm_bairro,
  ef.nm_empresa,
  ef.nm_fantasia_empresa,
  tp.nm_tabela_preco,
  cp.nm_condicao_pagamento,
  i.cd_portador,
  v.nm_fantasia_vendedor,
  fp.cd_forma_pagamento,
  fp.nm_forma_pagamento,
  isnull(i.ic_cobranca_eletronica,'N')  as ic_cobranca_eletronica,
  ISNULL(i.vl_limite_credito_cliente,0) as vl_limite_credito,
  p.nm_portador,
  i.cd_conta_banco,
  cab.nm_conta_banco,
  isnull(a.vl_documento_receber,0) as Atraso,
  ( select top 1 
      cc.cd_email_contato_cliente
    from
	  Cliente_Contato cc
    where
	  cc.cd_cliente = c.cd_cliente and
	  isnull(cc.ic_nfe_contato,'N')='S' ) as nm_email_nfe
   
   into
	#clienteVendedor

from 
  Cliente c                                    
  left outer join cliente_empresa ce           on ce.cd_cliente            = c.cd_cliente
  left outer join Tabela_Preco tp              on tp.cd_tabela_preco       = ce.cd_tabela_preco
  left outer join Cliente_Informacao_Credito i on i.cd_cliente             = c.cd_cliente
  LEFT outer join Condicao_Pagamento cp        on cp.cd_condicao_pagamento = c.cd_condicao_pagamento
  left outer join Portador p                   on p.cd_portador            = i.cd_portador
  left outer join Vendedor v                   on v.cd_vendedor            = c.cd_vendedor
  left outer join Forma_Pagamento fp           on fp.cd_forma_pagamento    = i.cd_forma_pagamento
  LEFT outer join Conta_Agencia_Banco cab      on cab.cd_conta_banco       = i.cd_conta_banco
  left outer join Empresa_Faturamento ef       on ef.cd_empresa            = ce.cd_empresa
  left outer join Cliente_Grupo cg             on cg.cd_cliente_grupo      = c.cd_cliente_grupo
  left outer join Cidade cid                   on cid.cd_cidade            = c.cd_cidade and cid.cd_estado = c.cd_estado  
  left outer join Estado e                     on e.cd_estado              = c.cd_estado
  left outer join #Atraso a                    on a.cd_cliente             = c.cd_cliente
where 
  ISNULL(c.cd_status_cliente,1) = 1
  and 
  isnull(v.cd_vendedor,0) = case when isnull(@cd_vendedor,0) = 0 then isnull(v.cd_vendedor,0) else isnull(@cd_vendedor,0) end 

order by
   cg.nm_cliente_grupo,
   c.nm_fantasia_cliente
	
------------------------------------------------------------------------------------------------------------		 
   
 if isnull(@cd_parametro,0) = 1  
 begin  
  select * from #clienteVendedor
  order by
    nm_fantasia_vendedor
  return  
 end  

--------------------------------------------------------------------------------------------------------------
declare @qt_total_cliente int 
select
	@qt_total_cliente = COUNT(cd_cliente)	
from #clienteVendedor
  
--------------------------------------------------------------------------------------------------------------
set @html_geral = '<div>
		<p class="section-title" style="text-align: center; padding: 8px;">Consulta Cliente por Vendedor</p>
	</div>
	<div>
    <table>  
		<tr class="tamanho">
		  <th>Vendedor</th>
		  <th>Código</th>
		  <th>Cliente</th>
		  <th>CNPJ</th>
		  <th>Razão Social</th>
		  <th>UF</th>
		  <th>Cidade</th>
		  <th>Bairro</th>
		  <th>Endereço</th>
		  <th>Tabela</th>
		  <th>Condição Pagamento</th>
		  <th>Forma</th>
		  <th>Grupo de Cliente</th>
		  <th>Empresa</th>
		  <th>Atraso</th>
		</tr>'
				   
--------------------------------------------------------------------------------------------------------------
DECLARE @id int = 0 

WHILE EXISTS (SELECT TOP 1 cd_controle FROM #clienteVendedor)
BEGIN
    SELECT TOP 1
        @id                          = cd_controle,

        @html_geral = @html_geral +
        '<tr class="tamanho">
            <td>' + isnull(nm_fantasia_vendedor,'') + '</td>
			<td>' + cast(isnull(cd_cliente,0)as nvarchar(15)) + '</td>
            <td style="text-align:left">' + isnull(nm_fantasia_cliente,'') + '</td>
			<td>' + cast(isnull(cd_cnpj_clientee,0) as nvarchar(20))+'</td>
			<td style="text-align:left">' + isnull(nm_razao_social_cliente,'') + '</td>
			<td>' + isnull(sg_estado,'') + '</td>
            <td>' + isnull(nm_cidade,'') + '</td>
			<td>' + isnull(nm_bairro,'') + '</td>
			<td>' + isnull(nm_endereco_cliente,'') + '</td>
            <td>' + isnull(nm_tabela_preco,'') + '</td>
            <td>' + isnull(nm_condicao_pagamento,'') + '</td> 
			<td>' + isnull(nm_forma_pagamento,'') + '</td>
			<td>' + isnull(nm_cliente_grupo,'') + ' ('+cast(isnull(cd_cliente_grupo,'') as nvarchar(15))+')</td> 
			<td>' + isnull(nm_fantasia_empresa,'') + '</td> 
			<td>' + dbo.fn_formata_valor(Atraso) + '</td> 
        </tr>'
		
		    FROM #clienteVendedor

    DELETE FROM #clienteVendedor WHERE cd_controle = @id
END
--------------------------------------------------------------------------------------------------------------------


set @html_rodape ='
           
	</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
	</div>
	<div class="section-title">
      <p>Total de Clientes: '+cast(isnull(@qt_total_cliente,0) as nvarchar(20))+'</p>
    </div>
	
	<div class="report-date-time">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>
    </div>
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
--exec pr_egis_relatorio_consulta_cliente_vendedor 243,0,''
------------------------------------------------------------------------------
