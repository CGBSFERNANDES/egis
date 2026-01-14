  IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_atendimento_consumidor' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_atendimento_consumidor

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_atendimento_consumidor
-------------------------------------------------------------------------------
--pr_relatorio_atendimento_consumidor
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : João Pedro Marçal
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis
--Data             : 10.01.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_relatorio_atendimento_consumidor
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
--declare @cd_documento           int = 0
declare @cd_parametro           int = 0
declare @dt_hoje                nvarchar(20)
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int

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

--set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
set @cd_parametro      = 0
set @cd_empresa        = 0
set @cd_form           = 0
set @cd_parametro      = 0
--set @cd_documento      = 0

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
set @dt_hoje = convert(nvarchar, getdate(), 103)
set @dt_hoje = convert(nvarchar, getdate(), 103)
---------------------------------------------------------------------------------------------------------------------------------------------
--Título do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------
--select * from egisadmin.dbo.relatorio

--select @dt_hoje
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
            font-size: 12px;
            margin: 0;
            padding: 20px;
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

        th, td {
            padding: 5px;
            text-align: left;
            vertical-align: top;
        }

        th {
            background-color: #f2f2f2;
            color: #333;
            text-align: center;
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

        .title {
            color: #1976D2;
        }


        p {
            margin: 5px;
            padding: 0;
			font-size: 18px;
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

-------------------------------- select cliente---------------------------------------------------------------------------------------------

---set @dt_hoje   = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)


select
   identity(int,1,1)                                    as cd_controle, 
   u.nm_fantasia_usuario                                AS FANTASIA_USUARIO,
   v.nm_fantasia_vendedor                               AS FANTASIA_VENDEDOR,
   c.nm_consumidor                                      AS nm_consumidor,
   cli.nm_fantasia_cliente                              as nm_fantasia_cliente,
   cli.nm_razao_social_cliente                          as razao_social,
   fa.nm_forma_atendimento                              as nm_forma_atendimento,
   sa.nm_status_atendimento                             as nm_status_atendimento,
   cr.nm_causa_reclamacao                               as nm_causa_reclamacao,
   mc.nm_manifestacao                                   as nm_manifestacao,
   ac.dt_compra_produto                                 as dt_compra_produto,
   ac.cd_identificacao_nota_saida                       as cd_identificacao_nota_saida,
   ac.dt_movimento                                      as dt_movimento,
   ac.hr_atendimento									as hora_atendimento,
   ac.dt_atendimento                                    as dt_atendimento,
   ac.dt_final_atendimento                              as dt_final_atendimento,
   ac.dt_previsao_atendimento                           as dt_previsao_atendimento,
   --Dados do Consumidor--------------------------------------------
   case when c.cd_tipo_pessoa = 1 then
     dbo.fn_formata_cnpj(c.cd_cpf_consumidor)
   else
     dbo.fn_formata_cpf(c.cd_cnpj_consumidor)
   end                                                   as CNPJ,

   c.cd_cep                                                as cd_cep,
   c.cd_identifica_cep                                     as cd_identifica_ceps,
   c.nm_endereco,
   c.cd_numero_endereco,
   c.nm_bairro,
   c.cd_estado                                             as cd_estado,
   
   ltrim(rtrim(c.nm_endereco))+', '+ltrim(rtrim(c.cd_numero_endereco))+ ' Bairro: '+ltrim(rtrim(c.nm_bairro)) as Endereco_Consumidor,

  
   isnull(stp.nm_status_consumidor,'') as nm_status_consumidor,

   pa.nm_pais,
   e.sg_estado,
   cid.nm_cidade                                          as nm_cidade_cos,
   tm.nm_tipo_mercado,
   tc.nm_tipo_cliente,
   fi.nm_fonte_informacao,
   tpe.nm_tipo_pessoa,

   c.cd_telefone                                         as cd_telefone,
   c.cd_telefone2,
   c.cd_fone_recado,
   c.cd_celular                                          as cd_celular,
   c.cd_skype,
   c.nm_email                                            as nm_email,

   tp.nm_tipo_prioridade                                 as nm_tipo_prioridade,

   --Dados do Produto---
    p.cd_mascara_produto                               as cd_mascara_produto,
    p.nm_fantasia_produto,
    p.nm_produto                                       as PRODUTO,
	ac.cd_pedido_venda                                 as pedido_venda,
	mp.nm_produto_atendimento                          as nm_produto_atendimento,
	mp.cd_lote                                         as cd_lote,
	mp.dt_fabricacao                                   as dt_fabricacao,
	mp.dt_validade                                     as dt_validade,
	mp.nm_obs_produto                                  as nm_obs_produto,
	mp.ds_produto_atendimento                          as ds_produto_atedimento,
	ac.ds_conclusao_atendimento                        as ds_conclusao_atendimento,
	ac.vl_financeiro_atendimento                       as vl_financeiro_atendimento,
	ac.dt_conclusao_atendimento                        as dt_conclusao_atendimento,
	c.cd_cliente                                       as cd_cliente,
    v.nm_fantasia_vendedor                             as nm_vendedor
	


	INTO
	#consumidor_atendimento


from
   Movimento_Atendimento ac
   left outer join egisadmin.dbo.usuario u             on u.cd_usuario                = ac.cd_usuario_atendimento
 --  left outer join vendedor v                          on v.cd_vendedor               = ac.cd_vendedor 
   left outer join consumidor c                        on c.cd_consumidor             = ac.cd_consumidor
   left outer join cliente cli                         on cli.cd_cliente              = ac.cd_cliente
   Left outer join vendedor v                          on v.cd_vendedor               = cli.cd_vendedor
   left outer join forma_atendimento fa                on fa.cd_forma_atendimento     = ac.cd_forma_atendimento
   left outer join status_atendimento sa               on sa.cd_status_atendimento    = ac.cd_status_atendimento
   left outer join causa_reclamacao cr                 on cr.cd_causa_reclamacao      = ac.cd_causa_reclamacao
   left outer join manifestacao_cliente mc             on mc.cd_manifestacao          = ac.cd_manifestacao
   left outer join tipo_prioridade tp                  on tp.cd_tipo_prioridade       = ac.cd_tipo_prioridade
   left outer join movimento_atendimento_produto mp    on mp.cd_movimento             = ac.cd_movimento
   left outer join produto p                           on p.cd_produto                = mp.cd_produto
   left outer join causa_reclamacao crp                on crp.cd_causa_reclamacao     = mp.cd_causa_reclamacao

   
   --Dados do Consumidor

  left join status_consumidor stp    on stp.cd_status_consumidor = c.cd_status_consumidor
  left join pais pa                  on pa.cd_pais               = c.cd_pais
  left join estado e                 on e.cd_estado              = c.cd_estado
  left join cidade cid               on cid.cd_cidade            = c.cd_cidade and cid.cd_estado = c.cd_estado
  left join tipo_cliente tc          on tc.cd_tipo_cliente       = c.cd_tipo_cliente
  left join fonte_informacao fi      on fi.cd_fonte_informacao   = c.cd_fonte_informacao
  left join tipo_mercado tm          on tm.cd_tipo_mercado       = c.cd_tipo_mercado
  left join tipo_pessoa tpe          on tpe.cd_tipo_pessoa       = c.cd_tipo_pessoa

where
  ac.cd_movimento = case when @cd_documento = 0 then ac.cd_movimento else @cd_documento end
  and
  ac.dt_movimento between case when @cd_documento=0 then @dt_inicial else ac.dt_movimento end and
                          case when @cd_documento=0 then @dt_final   else ac.dt_movimento end
order by
   ac.dt_movimento desc


--------------------------------------------------------------------------------------------------------------
declare @nm_consumidor                nvarchar(100)
declare @endereco_consumidor          nvarchar(100)
declare @cd_estado                    nvarchar(10)
Declare @nm_cidade_consumir           nvarchar(50)
declare @nm_produto_atendimento       nvarchar(60)
declare @cd_identifica_cep			  nvarchar(20)
declare @dt_compra_produto            nvarchar(20)
declare @cd_pedido_venda              nvarchar(20) 
declare @cd_identificacao_nota_saida  nvarchar(20)
declare @cd_telefone_consumidor       nvarchar(20)
declare @cd_celular                   int = 0
declare @nm_email                     nvarchar(30)
declare @dt_movimento                 nvarchar(20)
declare @hora_atendimento             nvarchar(10)
declare @nm_vendedor                  nvarchar(50)
declare @nm_fantasia_usuario          nvarchar(60)
declare @dt_atendimento               nvarchar(20)
declare @dt_final_atendimento         nvarchar(20)
declare @nm_tipo_prioridade           nvarchar(60)
declare @nm_manifestacao              nvarchar(60)
declare @nm_forma_atendimento         nvarchar(60)
declare @nm_causa_reclamacao          nvarchar(60)
declare @nm_fantasia_cliente          nvarchar(60)
declare @razao_social                 nvarchar(60)
declare @nm_status_atendimento        nvarchar(60)
declare @dt_previsao_atendimento      nvarchar(20)
declare @nm_produto                   nvarchar(60)
declare @cd_mascara_produto           int = 0
declare @cd_lote                      nvarchar(20)
declare @dt_fabricacao                nvarchar(20)
declare @dt_validade                  nvarchar(20)
declare @nm_obs_produto               nvarchar(60)
declare @ds_produto_atedimento        nvarchar(150)
declare @ds_conclusao_atendimento     nvarchar(60)
declare @cd_movimento                 int = 0
declare @cd_cep                       nvarchar(20)
declare @vl_financeiro_atendimento    float = 0
declare @nm_status_consumidor         nvarchar(20)
declare @dt_conclusao_atendimento     nvarchar(15)

select 

@nm_consumidor               = nm_consumidor,
@cd_estado                   = cd_estado,
@cd_identifica_cep           = cd_identifica_ceps,
@nm_cidade_consumir          = nm_cidade_cos,
@dt_compra_produto           = CONVERT(VARCHAR(10), dt_compra_produto, 103),
@cd_pedido_venda             = pedido_venda,
@cd_identificacao_nota_saida = cd_identificacao_nota_saida,
@cd_telefone_consumidor      = cd_telefone,
@cd_celular                  = cd_celular,
@nm_email                    = nm_email,
@dt_movimento                = CONVERT(VARCHAR(10), dt_movimento, 103),
@hora_atendimento            = convert(nvarchar, hora_atendimento, 108),
@nm_vendedor                 = nm_vendedor,
@nm_fantasia_usuario         = FANTASIA_USUARIO,
@dt_atendimento              = CONVERT(VARCHAR(10), dt_atendimento, 103),
@nm_tipo_prioridade          = nm_tipo_prioridade,
@nm_manifestacao             = nm_manifestacao,
@nm_causa_reclamacao         = nm_causa_reclamacao,
@nm_fantasia_cliente         = nm_fantasia_cliente,
@razao_social                = razao_social,
@nm_status_atendimento       = nm_status_atendimento,
@nm_produto                  = PRODUTO,
@cd_cep                      = cd_cep,
@endereco_consumidor         = Endereco_Consumidor,
@nm_forma_atendimento        = nm_forma_atendimento,
@nm_status_consumidor        = nm_status_consumidor,
@dt_conclusao_atendimento    = CONVERT(VARCHAR(10),dt_conclusao_atendimento, 103),
@dt_previsao_atendimento     = CONVERT(VARCHAR(10),dt_previsao_atendimento, 103)

from #consumidor_atendimento



--------------------------------------------------------------------------------------------------------------

set @html_geral ='<table style="border: 1px solid black; border-collapse: collapse;">
    <tr>
        <td style="text-align: center; font-weight: bold; border-right: none;">Registro de Atendimento<br>'+cast(isnull(@cd_documento,0) as nvarchar(15))+'</td>
        <td style="text-align: right; font-weight: bold; border-left: none;">DATA/HORA: '+@data_hora_atual+'</td>
    </tr>
</table>
<h1 style="text-align: center;">Entrada</h1>

<div style="display: flex; justify-content: space-between;gap: 10px ">
  <table style="border: 1px solid black;  width: 48%;">
      <tr>
          <td colspan="4">Consumidor: '+isnull(@nm_consumidor,'')+'</td>
      </tr>
      <tr>
          <td colspan="2">Endereço: '+isnull(@endereco_consumidor,'')+'</td>
          <td colspan="2">UF: '+isnull(@cd_estado,'')+'</td>
      </tr>
      <tr>
          <td colspan="2">Cidade: '+isnull(@nm_cidade_consumir,'')+'</td>
          <td colspan="2">CEP: '+isnull(@cd_cep,'')+'</td>

      </tr>
      <tr>
          <td colspan="2">Produto: '+isnull(@nm_produto,'')+'</td>
          <td colspan="2">Data da Compra: '+CAST(isnull(@dt_compra_produto,'') as nvarchar(15))+'</td>
      </tr>
      <tr>
          <td colspan="2">Pedido: '+CAST(isnull(@cd_pedido_venda,0) as nvarchar(15))+'</td>
          <td colspan="2">Nota Fiscal: '+cast(isnull(@cd_identificacao_nota_saida,0) as nvarchar(15))+'</td>
      </tr>
  </table>

  <table style="border: 1px solid black;  width: 48%;">
    <tr>
      <td colspan="2">Telefone: '+cast(isnull(@cd_telefone_consumidor,'') as nvarchar(20))+'</td>
      <td colspan="2">Celular: '+cast(isnull(@cd_celular,0) as nvarchar(15))+'</td>
      <td colspan="2">Email: '+isnull(@nm_email,'')+'</td>
      
    </tr>
    <tr>
        <td colspan="5">Vendedor: '+isnull(@nm_vendedor,'')+'</td>
    </tr>
    <tr>
      <td colspan="3">Entrada: '+cast(isnull(@dt_movimento,'') as nvarchar(15))+'</td>
      <td colspan="3">Hora: '+cast(isnull(@hora_atendimento,'')as nvarchar(15))+'</td>

    </tr>
    <tr>
      <td colspan="3">Atendido: '+ISNULL(@nm_fantasia_usuario,'')+'</td>
      <td colspan="3">Atendimento: '+cast(isnull(@dt_atendimento,'') as nvarchar(15))+'</td>
    </tr>
    <tr>
      <td colspan="5">Conclusão: '+cast(isnull(@dt_conclusao_atendimento,'') as nvarchar(15))+'</td>
    </tr>
</table>
</div>

<table>
    <tr>
        <td>Prioridade: '+isnull(@nm_tipo_prioridade,'')+'</td>
        <td>Manifestação: '+isnull(@nm_manifestacao,'')+'</td>
        <td>Forma de Atendimento: '+isnull(@nm_forma_atendimento,'')+'</td>
        <td>Causa da Reclamação: '+isnull(@nm_causa_reclamacao,'')+'</td>
       
    </tr>
    <tr>
         <td>Cliente: '+isnull(@nm_fantasia_cliente,'')+'</td>
         <td> '+isnull(@razao_social,'')+'</td>
         <td>Status: '+isnull(@nm_status_consumidor,'')+'</td>
         <td>Previsão: '+cast(isnull(@dt_previsao_atendimento,'')as nvarchar(15))+'</td>
    </tr>
</table>
<table>
	<tr class="section-title">
		<td colspan="7">PRODUTOS</td>
	</tr>
	</table>'
					   
--------------------------------------------------------------------------------------------------------------
declare @id int = 0

if not exists (select top 1 cd_controle from #consumidor_atendimento)
	begin

while exists ( select top 1 cd_controle from #consumidor_atendimento)
begin
	select top 1
		@id                          = cd_controle,
		@nm_produto_atendimento      = nm_produto_atendimento,
		@cd_mascara_produto          = cd_mascara_produto,
		@cd_lote                     = cd_lote,
		@dt_fabricacao               = CONVERT(VARCHAR(10), dt_fabricacao, 103),
		@dt_validade                 = CONVERT(VARCHAR(10), dt_validade, 103),
		@nm_obs_produto              = nm_obs_produto,
		@ds_produto_atedimento       = ds_produto_atedimento,
		@ds_conclusao_atendimento    = ds_conclusao_atendimento,
		@dt_final_atendimento        = CONVERT(VARCHAR(10), dt_final_atendimento, 103),
		@vl_financeiro_atendimento   = vl_financeiro_atendimento

	from #consumidor_atendimento

  set @html_geral = @html_geral +'<table>
									<tr>
										<th>Item</th>
										<th>Descrição</th>
										<th>Código</th>
										<th>Lote</th>
										<th>Fabricação</th>
										<th>Validade</th>
										<th>Observação</th>
									</tr>
									<tr>
										<td> '+cast(isnull(@id,'')as nvarchar(5))+'</td>
										<td> '+isnull(@nm_produto_atendimento,'')+'</td>
										<td> '+cast(isnull(@cd_mascara_produto,'') as nvarchar(12))+'</td>
										<td> '+isnull(@cd_lote,'')+'</td>
										<td> '+cast(isnull(@dt_fabricacao,'') as nvarchar(15))+'</td>
										<td> '+cast(isnull(@dt_validade,'') as nvarchar(15))+'</td>
										<td> '+isnull(@nm_obs_produto,'')+'</td>
									</tr>
									<tr>
										<td colspan="4">Descrição: '+isnull(@ds_produto_atedimento,'')+'</td>
										<td colspan="3">Causa: </td>
									</tr>    
								</table>
								<table>
										<tr>
											<td colspan="3">Valor Financeiro R$: '+cast(isnull(@vl_financeiro_atendimento,'') as nvarchar(10))+'</td>
										</tr>
										<tr>
										  <td colspan="1">Conclusão: '+cast(isnull(@dt_final_atendimento,'') as nvarchar(15))+'</td>
										  <td> '+isnull(@ds_conclusao_atendimento,'')+'</td>
									  </tr>
								</table>'

     
	 delete from #consumidor_atendimento where cd_controle = @id
 end
  end
 
---------------------------------------------------------------------------------------------------------------

declare @html_totais nvarchar(max)=''
declare @titulo_total varchar(500)=''

set @html_rodape =
	'<div style="width:100%; justify-content: space-between; display: flex;"> 
			<img src="'+isnull(@logo,'')+'" alt="Logo da Empresa">
			<img src="'+isnull(@logo,'')+'" alt="Logo da Empresa"> 
			<img src="'+isnull(@logo,'')+'" alt="Logo da Empresa">
			<img src="'+isnull(@logo,'')+'" alt="Logo da Empresa">
    </div>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
	<div class="report-date-time">
       <p style="text-align:right; margin-top:30px">Gerado em: '+@data_hora_atual+'</p>
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
--exec pr_relatorio_atendimento_consumidor 225,1,'' 
------------------------------------------------------------------------------

