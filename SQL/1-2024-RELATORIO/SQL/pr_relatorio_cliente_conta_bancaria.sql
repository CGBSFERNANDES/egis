IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_cliente_conta_bancaria' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_cliente_conta_bancaria

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_cliente_conta_bancaria
-------------------------------------------------------------------------------
--pr_relatorio_cliente_conta_bancaria
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Joao Pedro Marcal
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatorio Padrao Egis HTML - EgisMob, EgisNet, Egis
--Data             : 10.01.2025
--Alteracao        : 
--
--
------------------------------------------------------------------------------
create procedure pr_relatorio_cliente_conta_bancaria
@cd_relatorio int   = 0,
@cd_documento int   = 0,
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
--declare @cd_documento           int = 0
declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @ic_valor_comercial     varchar(10)
declare @cd_tipo_destinatario   int 
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
set @cd_parametro      = 0
set @cd_empresa        = 0
set @cd_form           = 0
set @cd_parametro      = 0
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
  select @cd_documento           = valor from #json where campo = 'cd_empresa'
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
/*
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
*/
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
	<script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.2/html2pdf.bundle.min.js" integrity="sha512-MpDFIChbcXl2QgipQrt1VcPHMldRILetapBl5MPCA9Y8r7qvlwx1/Mc9hNTzY+kS5kX6PdoDq41ws1HiVNLdZA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
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
		tr {
			page-break-inside: avoid;  
			page-break-after: auto;
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
		#salva {
			  background-color: #1976D2;
			  color: white;
			  border: none;
			  padding: 10px 20px;
			  font-size: 16px;
			  cursor: pointer;
			  border-radius: 5px;
			  transition: background-color 0.3s;
			}

	   #salva:hover {
			  background-color: #1565C0;
			}
	   .nao-imprimir {
            display: none;
        }
	</style>
</head>
<body>
   <div id="conteudo">
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

		

--Detalhe--
--Procedure de Cada Relat�rio-------------------------------------------------------------------------------------

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

--select @nm_dados_cab_det

--select @nm_grupo_relatorio,@nm_dados_cab_det,* from #RelAtributo
declare @data_inical_teste datetime
declare @data_final_teste datetime

set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)


--------------------------------------------------------------------------------------------------------------------------
--declare @cd_vendedor int = 0

select
 identity(int,1,1)          as cd_controle,
 ef.cd_empresa              as cd_empresa,
 ef.nm_fantasia_empresa     as nm_fantasia_empresa,     --Empresa
 c.cd_cliente               as cd_cliente,              --Código
 c.nm_fantasia_cliente      as nm_fantasia_cliente,     --Cliente
 c.nm_razao_social_cliente  as nm_razao_social_cliente, --Razao Social,
 c.cd_cnpj_cliente          as cd_cnpj_cliente,         --CNPJ
 c.cd_vendedor              as cd_vendedor,            
 v.nm_fantasia_vendedor     as nm_fantasia_vendedor,    --Vendedor
 cab.nm_conta_banco         as nm_conta_banco,          --Conta
 b.nm_banco                 as nm_banco                 --Banco
 INTO 
 #conta_cliente

  from
    cliente c
	left outer join Cliente_Informacao_Credito i on i.cd_cliente = c.cd_cliente
    left outer join cliente_empresa ce                on ce.cd_cliente = c.cd_cliente
	left outer join Empresa_Faturamento ef            on ef.cd_empresa = ce.cd_empresa
	left outer join Conta_Agencia_Banco cab      on cab.cd_conta_banco = case when isnull(ce.cd_conta_banco,0) = 0 then i.cd_conta_banco else ce.cd_conta_banco end
	left outer join Banco b                      on b.cd_banco = cab.cd_banco
    left outer join Vendedor v                   on v.cd_vendedor = c.cd_vendedor
 where
    ef.cd_empresa = 1
    and (
        (@cd_empresa <> 274 and ce.cd_empresa in (2,3))
        or (@cd_empresa = 274)
    )
    and isnull(c.cd_status_cliente,0) = 1

	order by
	  c.nm_fantasia_cliente

	 

--------------------------------------------------------------------------------------------------------------
declare @nm_razao_social_cliente     nvarchar(60)
declare @cd_cnpj_cliente_tb          nvarchar(20)
declare @cd_vendedor                 int = 0
declare @nm_fantasia_vendedor        nvarchar(60)
declare @nm_conta_banco              nvarchar(40) 
declare @cd_cliente_tb               int = 0 
declare @nm_fantasia_cliente         nvarchar(60)
declare @nm_fantasia_empresa_tb      nvarchar(60)
declare @nm_banco                    nvarchar(40)
declare @qt_total                    int = 0

select 
	@qt_total = count(cd_cliente)
from #conta_cliente

--------------------------------------------------------------------------------------------------------------
set @html_geral = '<div>
		<p class="section-title" style="text-align: center; padding: 8px;">Clientes x Contas Bancárias</p>
	</div>
		<div>
			<table>
				<tr>
                    <th>Empresa</th>
                    <th>Código</th>
                    <th>Cliente</th>
                    <th>Razão Social</th>
                    <th>CNPJ</th>
                    <th>Vendedor</th>
                    <th>Conta</th>
                    <th>Banco</th>
                <tr>'

					
--------------------------------------------------------------------------------------------------------------
DECLARE @id int = 0 

WHILE EXISTS (SELECT TOP 1 cd_controle FROM #conta_cliente)
BEGIN
    SELECT TOP 1
        @id                          = cd_controle,
		@nm_razao_social_cliente     = nm_razao_social_cliente,
        @nm_fantasia_cliente         = nm_fantasia_cliente,
        @nm_fantasia_vendedor        = nm_fantasia_vendedor,
		@cd_vendedor                 = cd_vendedor,
		@cd_cnpj_cliente_tb          = cd_cnpj_cliente,
		@nm_conta_banco              = nm_conta_banco,
		@cd_cliente                  = cd_cliente, 
		@nm_fantasia_empresa_tb      = nm_fantasia_empresa,
		@nm_banco                    = nm_banco
 
    FROM #conta_cliente

    SET @html_geral = @html_geral +
        '<tr>
		    <td>'+isnull(@nm_fantasia_empresa,'')+'</td>
			<td>'+cast(isnull(@cd_cliente,'') as nvarchar(20))+'</td>
			<td>'+isnull(@nm_fantasia_cliente,'') +'</td>
			<td>'+isnull(@nm_razao_social_cliente,'') +'</td>
			<td>'+isnull(dbo.fn_formata_cnpj(@cd_cnpj_cliente_tb),'')+'</td>
            <td>'+isnull(@nm_fantasia_vendedor,'')+' ('+cast(isnull(@cd_vendedor,'') as nvarchar(10))+')</td>
			<td>'+isnull(@nm_conta_banco,'')+'</td>
			<td>'+isnull(@nm_banco,'')+'</td>		
        </tr>'

    DELETE FROM #conta_cliente WHERE cd_controle = @id
END
--------------------------------------------------------------------------------------------------------------------



set @html_rodape =
    '</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
	</div>
	<div>
		<p class="section-title">Total de Clientes: '+cast(isnull(@qt_total,'') as nvarchar(10))+'</p>
	</div>
	<div class="report-date-time">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>
	  <button id="salva">Salvar</button>
    </div>
	<script>
            document.querySelector("#salva").addEventListener("click", () => {
                const botaoSalvar = document.querySelector("#salva");
                botaoSalvar.classList.add("nao-imprimir");

                const conteudoHtml = document.querySelector("#conteudo");
                const options = {
                    margin: 10,
                    filename: "'+isnull(@titulo,'')+'.pdf",
                    image: { type: "jpeg", quality: 0.98 },
                    html2canvas: {
                        scale: 1,
                        scrollX: 0,
                        scrollY: 0,
                        windowWidth: document.body.scrollWidth,
                        windowHeight: document.body.scrollHeight,
                        useCORS: true
                    },
                    jsPDF: { unit: "mm", format: "a4", orientation: "landscape" },
                };

                html2pdf()
                    .set(options)
                    .from(conteudoHtml)
                    .save()
                    .then(() => {
                        botaoSalvar.classList.remove("nao-imprimir"); 
                    });
            });
        </script>	

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
--exec pr_relatorio_cliente_conta_bancaria 233,0,''
------------------------------------------------------------------------------
