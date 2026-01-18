IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_tabela_preco_lookup' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_tabela_preco_lookup

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_categoria_produto
-------------------------------------------------------------------------------
--pr_egis_relatorio_diario_pedidos_separacao
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
create procedure pr_relatorio_tabela_preco_lookup
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
	--		@nm_fantasia_cliente  	    varchar(200) = '',
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

-------------------------------------------------------------------------------------------------

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio_form'


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
      }
      table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 20px;
      }
      table, th, td {
        border: 1px solid #ddd;
      }
      th, td {
        padding: 5px;
      }
      th {
        color: #333;
        text-align: center;
      }
      header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 20px;
        background-color: #1976d2;
        color: white;
      }
      header img {
        max-width: 120px;
      }
      header .company-info {
        text-align: right;
      }
      header .company-info p {
        margin: 0;
      }
      .container {
        max-width: 87%;
        margin: 30px auto;
        background-color: white;
        padding: 20px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        border-radius: 10px;
      }
      .section {
        margin-bottom: 20px;
        text-align: center;
      }
      button {
        background-color: #1976d2;
        color: white;
        font-size: 14px;
        border: none;
        padding: 10px 15px;
        border-radius: 5px;
        cursor: pointer;
        margin: 5px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        transition: background-color 0.3s ease;
      }
      button:hover {
        background-color: #155a9d;
      }
      select {
        width: 45%;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 5px;
        font-size: 14px;
        margin: 5px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
      }
	  .tamanho{
		text-align: center;
	  }
	  .section-title {
            background-color: #1976D2;
            color: white;
            padding: 5px;
            margin-bottom: 15px;
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

--select @nm_dados_cab_det

--select @nm_grupo_relatorio,@nm_dados_cab_det,* from #RelAtributo

set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
--------------------------------------------------------------------------------------------------------------------------
select 
  identity(int,1,1) as cd_controle,
  tp.cd_tabela_preco as cd_documento,
  tp.cd_tabela_preco,
  tp.nm_tabela_preco,
  tp.sg_tabela_preco,
  tp.cd_tipo_tabela_preco,
  ttp.nm_tipo_tabela_preco,
  tp.cd_condicao_pagamento,
  cp.nm_condicao_pagamento,
  tp.cd_tipo_pedido,
  tip.nm_tipo_pedido
into
    #Tabela_Preco_Grid
from
  Tabela_Preco tp with(nolock)  --select * from Tabela_Preco
  left outer join Tipo_Tabela_Preco ttp with(nolock) on ttp.cd_tipo_tabela_preco = tp.cd_tipo_tabela_preco
  left outer join Condicao_Pagamento cp with(nolock) on cp.cd_condicao_pagamento = tp.cd_condicao_pagamento
  left outer join Tipo_Pedido       tip with(nolock) on tip.cd_tipo_pedido       = tp.cd_tipo_pedido
where
 isnull(tp.ic_status_tabela_preco,'I') = 'A'
 

 --select * from #Tabela_Preco_Grid
-- select * from Tabela_Preco_Produto
-------------------------------------------------------------------------------------------------------------
declare @capa_tabela nvarchar(MAX)
 
 set @capa_tabela = (select  * from #Tabela_Preco_Grid for json auto)
--------------------------------------------------------------------------------------------------------------
select 
  tp.cd_tabela_preco                                  as cd_tabela_preco,
  tp.nm_tabela_preco							      as nm_tabela_preco,
  p.cd_mascara_produto                                as cd_mascara_produto,
  p.nm_produto                                        as nm_produto,
  um.sg_unidade_medida                                as sg_unidade_medida,
  p.qt_multiplo_embalagem                             as qt_multiplo_embalagem
  
  into
  #produto
from
  Tabela_Preco_Produto tpp 
  inner join Tabela_Preco tp              on tp.cd_tabela_preco   = tpp.cd_tabela_preco
  inner join produto p                    on p.cd_produto         = tpp.cd_produto
  left outer join unidade_medida um       on um.cd_unidade_medida = p.cd_unidade_medida
  left outer join egisadmin.dbo.usuario u on u.cd_usuario         = tpp.cd_usuario
  left outer join Produto_Saldo ps        on ps.cd_produto        = tpp.cd_produto and ps.cd_fase_produto = p.cd_fase_produto_baixa
 where
    isnull(tp.ic_status_tabela_preco,'I') = 'A'
   and
   ISNULL(p.cd_status_produto,1)=1
 
order by
  tp.nm_tabela_preco,
  p.nm_produto	

declare @nm_produto            nvarchar(50)
declare @sg_unidade_medida     nvarchar(5)
declare @qt_multiplo_embalagem nvarchar(5)
declare @tabela_produto nvarchar(max)
-------------------------------------------------------------------------------------------------------------
set @tabela_produto = (select 
						nm_tabela_preco,
						nm_produto,
						cast(sg_unidade_medida AS nvarchar(2))     as sg_unidade_medida,
						cast(qt_multiplo_embalagem as nvarchar(5)) as qt_multiplo_embalagem
                       from #produto for json auto)


-------------------------------------------------------------------------------------------------------------



 --set @tabela_produto= (select * from #produto for json auto)

--select @tabela_produto
 
 --const dadosProduto 
--------------------------------------------------------------------------------------------------------------
set @html_geral = '<div >
    <p style="text-align: center" class="section-title">Consulta Tabela Preço</p>
    <div class="section"> <select id="tabelaPrecos">
        <option value="" disabled selected>Selecione uma tabela de Preço</option>
      </select> </div>
    <div class="section">
      <table id="tabelaDinamica">
          <tr>
            <th>Produto</th>
            <th>Unidade Medida</th>
            <th>Multiplo Embalagem</th>
            <th>Valor Produto</th>
            <th>Valor Total</th>
            <th>Grupo</th>
            <th>N.C.M</th>
          </tr>
      </table>
    </div>
  </div>
    <script>
      const dadosTabela = '+isnull(@capa_tabela,'')+';
      function popularSelect() {
    const selectElement = document.getElementById("tabelaPrecos");

    dadosTabela.forEach((tabela) => {
      const option = document.createElement("option");
      option.value = tabela.cd_tabela_preco;
      option.textContent = tabela.nm_tabela_preco;
      selectElement.appendChild(option);
    });
  }

  async function gerarTabela() {
    const tabela = document.getElementById("tabelaDinamica");
    const tabelaPrecos = document.getElementById("tabelaPrecos");
    const valorSelecionado = parseInt(tabelaPrecos.value, 10);

    try {
      console.log("Valor selecionado:", valorSelecionado);

      const dados = await fetch(
        `https://egisnet.com.br/api/856/1333/317/249/0/142/2210/7945/${valorSelecionado}/01-01-2025/12-31-2025/0/0`
      );

      const dadosProduto = await dados.json();
      const produtos = Array.isArray(dadosProduto) ? dadosProduto : [dadosProduto];

      tabela.innerHTML = `
        <tr>
          <th>Produto</th>
          <th>Unidade Medida</th>
          <th>Multiplo Embalagem</th>
          <th>Valor Produto</th>
          <th>Valor Total</th>
          <th>Grupo</th>
          <th>N.C.M</th>
        </tr>
      `;


produtos.forEach((produto) => {
  tabela.innerHTML += `
    <tr>
      <td class="tamanho">${produto.nm_produto} (${produto.cd_mascara_produto})</td>
      <td class="tamanho">${produto.nm_unidade_medida}</td>
      <td class="tamanho">${produto.qt_multiplo_embalagem}</td>
      <td class="tamanho">${parseFloat(produto.vl_tabela_produto).toFixed(2).replace(".", ",")}</td>
      <td class="tamanho">${produto.vl_total_multiplo.toFixed(2).replace(".", ",")}</td>
      <td class="tamanho">${produto.nm_grupo_produto}</td>
      <td class="tamanho">${produto.cd_mascara_classificacao}</td>
    </tr>
  `;
});
    } catch (err) {
      tabela.innerHTML = `
        <tr>
          <td style="color:red; text-align:center" colspan="7">
            Erro ao carregar os dados, tente novamente.
          </td>
        </tr>
      `;
      console.error("Erro ao buscar dados:", err);
    }
  }

  document.addEventListener("DOMContentLoaded", () => {
    popularSelect();

    const tabelaPrecos = document.getElementById("tabelaPrecos");
    tabelaPrecos.addEventListener("change", gerarTabela);
  });
</script>'
  
--------------------------------------------------------------------------------------------------------------------
declare @html_totais nvarchar(max)=''
declare @titulo_total varchar(500)=''
	
set @html_rodape =
    '</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
   
    <p>'+@ds_relatorio+'</p>
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
--exec pr_relatorio_tabela_preco_lookup 223,'' 
------------------------------------------------------------------------------

