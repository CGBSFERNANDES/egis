IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_diario_comodato' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_diario_comodato

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_diario_comodato
-------------------------------------------------------------------------------
--pr_egis_relatorio_diario_comodato
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Joao Pedro Marcal
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relat�rio Padr�o Egis HTML - EgisMob, EgisNet, Egis
--Data             : 18.03.2025
--Altera��o        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_diario_comodato
@cd_relatorio int   = 0,
@cd_parametro int   = 0, 
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as
print 'iniciou a pr_egis_relatorio_diario_comodato'
set @json = isnull(@json,'')
declare @data_grafico_bar            nvarchar(max) = '',
        @cd_empresa                  int = 0,
        @cd_form                     int = 0,
        @cd_usuario                  int = 0,
        @cd_documento                int = 0,
        @dt_hoje                     datetime,
        @dt_inicial                  datetime,
        @dt_final                    datetime,
        @cd_ano                      int = 0 ,  
        @cd_mes                      int = 0 ,  
        @cd_dia                      int = 0,
        @ic_valor_comercial          varchar(10) = '',
        @cd_tipo_destinatario        int = 0,
        @cd_grupo_relatorio          int = 0,
        @cd_vendedor                 int = 0,
        @dt_base_incial              datetime,
        @dt_base_final               datetime,
        @vl_meta                     decimal(25,2) = 0.00,
        @vl_total                    decimal(25,2) = 0.00,
        @pc_atingido                 decimal(25,2) = 0.00,
        @html                        nvarchar(max) = '', --Total
        @html_empresa                nvarchar(max) = '', --Cabe�alho da Empresa
        @html_titulo                 nvarchar(max) = '', --T�tulo
        @html_cab_det                nvarchar(max) = '', --Cabe�alho do Detalhe
        @html_detalhe                nvarchar(max) = '', --Detalhes
        @html_rod_det                nvarchar(max) = '', --Rodap� do Detalhe
        @html_rodape                 nvarchar(max) = '', --Rodape
        @html_geral                  nvarchar(max) = '', --Geral
        @data_hora_atual             nvarchar(50)  = '',
		@cd_item_relatorio           int           = 0,  
        @nm_cab_atributo             varchar(100)  = '',
        @nm_dados_cab_det            nvarchar(max) = '',  
        @nm_grupo_relatorio          varchar(60)   = '',
		@ic_produto_faturamento      char(1)       = '',
		@ic_fat_categoria            char(1)       = '',
		@hr_inicial_pedido           varchar(10)   = '',
        @nm_fantasia_vendedor        varchar(60)   = '',
        @dt_pedido_venda             varchar(20)   = '',
        @cd_pedido_venda             int           = 0 ,
        @nm_tipo_pedido              varchar(60)   = '',
        @cd_cliente_tb               varchar(20)   = '',
        @nm_fantasia_cliente         varchar(60)   = '',
        @vl_total_pedido             varchar(20)   = '',
        @sg_estado_tb                varchar(20)   = '',
        @nm_cidade_tb                varchar(60)   = '',
        @nm_condicao_pagamento_tb    varchar(40)   = '',
        @nm_forma_pagamento          varchar(40)   = '',
        @vl_total_grupo              INT           = 0,
        @qt_total                    INT           = 0,
		@cd_tipo_consulta            int           = 0,
	    @id                          int		   = 0 
set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
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

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'

   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'
   end
 --  if isnull(@cd_vendedor,0) = 0
 --   begin 
	--	set @cd_parametro = dbo.fn_usuario_vendedor(@cd_usuario)  
	--end
 --  else 
	--begin
	--	set @cd_parametro = @cd_vendedor
	--	end
end


---set @cd_vendedor = dbo.fn_usuario_vendedor(@cd_usuario)
-------------------------------------------------------------------------------------------------
--declare @ic_processo char(1) = 'N'  
   
  
select  
  @titulo             = nm_relatorio,  
  --@ic_processo        = isnull(ic_processo_relatorio, 'N'),  
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)  
from  
  egisadmin.dbo.Relatorio  
where  
  cd_relatorio = @cd_relatorio  
--------------------------------------------------------------------------------------------------------------------------
select  
  @dt_inicial       = isnull(@dt_inicial,''),
  @dt_final         = isnull(@dt_final,'')
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
set @dt_base_incial   = dbo.fn_data_inicial(@cd_mes,@cd_ano)
set @dt_base_final    = dbo.fn_data_final(@cd_mes,@cd_ano)

if @dt_inicial is null  or @dt_inicial = '01/01/1900'    
begin      
      
  set @cd_ano = year(@dt_hoje)      
  set @cd_mes = month(@dt_hoje)      
      
  set @dt_inicial = dbo.fn_data_inicial(@cd_mes,@cd_ano)      
  set @dt_final   = dbo.fn_data_final(@cd_mes,@cd_ano)      
      
end   

select
  @dt_inicial = max(c.dt_consulta)
from
  consulta c
where
  c.cd_consulta in ( select i.cd_consulta from consulta_itens i where i.cd_consulta = c.cd_consulta 
                     and
					 i.dt_perda_consulta_itens is null
					 and
					 isnull(i.cd_pedido_venda,0) = 0 )




set @cd_empresa = dbo.fn_empresa()

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


--  data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)

-------------------------------------------------------------------------------------------------


SET @html_empresa = '
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title >'+isnull(@titulo,'')+'</title>
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
            font-size: 12px;
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
   
  
select * into #AuxRelAtributo from #RelAtributo  
where  
  cd_grupo_relatorio = @cd_grupo_relatorio  
  
order by qt_ordem_atributo  
  

  
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
  

--set @dt_inicial = '03-17-2025'
--set @dt_final   = '03-17-2025'

--------------------------------------------------------------------------------------------------------------------------
  
set @cd_cliente       = isnull(@cd_cliente,0)  
set @cd_tipo_consulta = isnull(@cd_tipo_consulta,0)  
set @cd_usuario       = isnull(@cd_usuario,0)  
--set @ic_egismob       = ISNULL(@ic_egismob,'N')  
  
--if @cd_parametro is null or @cd_parametro = 0  
--  set @cd_parametro = 0  
  
if @cd_usuario > 0  
begin  
  set @cd_parametro = dbo.fn_usuario_vendedor(@cd_usuario)  
end  
  
--select @cd_parametro, @cd_usuario  
  
SET DATEFORMAT mdy  
  
  
  
set @cd_ano = year(getdate())  
set @cd_mes = month(getdate())  
  
  --set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)  
  --set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)  
  
  
if @dt_inicial is null  
begin  
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)  
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)  
end  
  
set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)  
set @vl_total         = 0.00  
set @ic_fat_categoria = '0'  
set @cd_empresa       = dbo.fn_empresa()  
set @dt_base_incial   = dbo.fn_data_inicial(@cd_mes,@cd_ano)  
set @dt_base_final    = dbo.fn_data_final(@cd_mes,@cd_ano)  
  
  
set @ic_produto_faturamento = 'N'  
  
--config_egismob------------------------------------------------------------------------------------------------------------------------  
  
select  
  @ic_produto_faturamento = isnull(ic_produto_faturamento,'N')  
  
from  
  config_egismob with (nolock)  
  
where  
  cd_empresa = @cd_empresa --dbo.fn_empresa()   
    
  
------------------------------------------  

select
  right(left(convert(varchar,p.hr_inicial_pedido,121),16),5) as hr_inicial_pedido,
  --p.hr_inicial_pedido, 
--  dbo.fn_hora_string(p.hr_inicial_pedido) as hr_inicial_pedido,
  p.cd_pedido_venda,
  p.dt_pedido_venda,
  tp.nm_tipo_pedido,
  c.cd_cliente,
  c.nm_fantasia_cliente,
  v.cd_vendedor,
  v.nm_fantasia_vendedor,
  max(isnull(p.vl_total_pedido_ipi,0))                                        as vl_total,
  max(i.cd_usuario_ordsep)                                                    as cd_usuario_ordsep,
  max(i.dt_ordsep_pedido_venda)                                               as dt_ordsep_pedido_venda,
  max(isnull(i.ic_ordsep_pedido_venda,'N'))                                   as ic_ordsep_pedido_venda,
  max(isnull(ef.nm_fantasia_empresa,''))                                      as nm_fantasia_empresa,
  max(cid.nm_cidade)                                                          as nm_cidade

  into
    #Diario_Comodato

from
  pedido_venda p
  
  inner join cliente c                      on c.cd_cliente                 = p.cd_cliente
  inner join cidade cid                     on cid.cd_cidade                = c.cd_cidade
  left outer join tipo_pedido tp            on tp.cd_tipo_pedido            = p.cd_tipo_pedido
  inner join vendedor v                     on v.cd_vendedor                = case when isnull(p.cd_vendedor,0)=0 then c.cd_vendedor else p.cd_vendedor end
  inner join pedido_venda_item i            on i.cd_pedido_venda            = p.cd_pedido_venda
  left outer join pedido_venda_empresa pve  on pve.cd_pedido_venda          = p.cd_pedido_venda
  left outer join empresa_faturamento ef    on ef.cd_empresa                = pve.cd_empresa
  inner join Solicitacao_Ativo sa           on sa.cd_pedido_venda           = p.cd_pedido_venda 

where
  p.dt_pedido_venda between @dt_inicial and @dt_final
  and
  --c.cd_vendedor           = case when @cd_parametro = 0 then c.cd_vendedor           else @cd_parametro end
  --and
  isnull(p.cd_vendedor,0) = case when @cd_parametro = 0 then isnull(p.cd_vendedor,0) else @cd_parametro end

  and

  i.dt_cancelamento_item is null
 
group by
  p.hr_inicial_pedido, 
  p.cd_pedido_venda,
  p.dt_pedido_venda,
  tp.nm_tipo_pedido,
  c.cd_cliente,
  c.nm_fantasia_cliente,
  v.cd_vendedor,
  v.nm_fantasia_vendedor


  order by
    p.cd_pedido_venda

  --select * from #Diario


  --declare @vl_total decimal(25,2) = 0.00

  select
     @qt_total = count(distinct cd_pedido_venda ), 
     @vl_total = sum(isnull(d.vl_total,0))

	 --@vl_meta  = sum( case when ISNULL(mvp.vl_meta_vendedor,0)>0 then mvp.vl_meta_vendedor
	 --    else 
		--   ISNULL(v.vl_meta,0)
		-- end
	 --  )       

  from
    #Diario_Comodato d
	left outer join vendedor v                on v.cd_vendedor = d.cd_vendedor
    left outer join Meta_Vendedor_Periodo mvp on mvp.cd_vendedor              = d.cd_vendedor and 
	                                           mvp.dt_inicial_validade_meta = @dt_base_incial and
											   mvp.dt_final_validade_meta   = @dt_base_final  

  select
    

	 @vl_meta  = sum( case when ISNULL(mvp.vl_meta_vendedor,0)>0 then mvp.vl_meta_vendedor
	     else 
		   ISNULL(v.vl_meta,0)
		 end
	   )       

  from
    Vendedor v
	    left outer join Meta_Vendedor_Periodo mvp on mvp.cd_vendedor              = v.cd_vendedor and 
	                                           mvp.dt_inicial_validade_meta = @dt_base_incial and
											   mvp.dt_final_validade_meta   = @dt_base_final  
  where
    isnull(v.cd_vendedor,0) = case when isnull(@cd_parametro,0) = 0 then  isnull(v.cd_vendedor,0) else isnull(@cd_parametro,0) end

  set @pc_atingido    = case when isnull(@vl_meta,0)> 0 then ROUND(@vl_total/@vl_meta*100,2) else 0.00 end

  select
     identity(int,1,1) as cd_controle,
     v.*,
	 pc_faturamento = case when @vl_total>0                     then round(v.vl_total/@vl_total*100,2)          else 0.00 end
	 --pc_atingido    = case when isnull(v.vl_meta_vendedor,0)> 0 then ROUND(v.vl_total/v.vl_meta_vendedor*100,2) else 0.00 end
	
  into
    #FinalDiario_Comodato

  from
    #Diario_Comodato v

   order by
     vl_total desc

   select   
        cd_controle,   
   'S'                                                                  as 'MultipleDate',  
   'currency-usd'                                                       as 'iconHeader',     
   nm_fantasia_cliente +'('+CAST(cd_cliente as varchar(9))+')'          as caption,
   --cast(qt_nota as varchar)
   hr_inicial_pedido                                                    as 'badgeCaption',
   CAST(cd_pedido_venda as varchar(20))                                 as quantidade,  
   nm_tipo_pedido                                                       as tipoPedido,
   dbo.fn_data_string(dt_pedido_venda)                                  as subcaption1,  
   dbo.fn_formata_valor(vl_total)                                       as resultado,  
   nm_cidade                                                            as resultado1,   
   nm_fantasia_empresa                                                  as resultado2,
   nm_fantasia_vendedor                                                 as 'resultado3',
   dbo.fn_formata_valor(@vl_total)                                      as titleHeader,  
   cast(cast(@qt_total as int ) as varchar(2)) 
	                                                                    as subtitle2Header,  
   dbo.fn_formata_valor( pc_faturamento)                                as percentual 

		into
		#resulHTML
      from #FinalDiario_Comodato b  
      order by          
	    cd_pedido_venda desc

--------------------------------------------------------------------------------------------------------------------------
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #resulHTML  
  return  
 end  

--------------------------------------------------------------------------------------------------------------

set @html_geral = '   
     <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 10%;">Diário de Comodato</p>  
    </div>  
	<div>
    <table>
      <tr class="tamanho">
          <th>Cliente</th>
          <th>Pedido</th>
          <th>Tipo Pedido</th>
          <th>Emissão</th>
          <th>Cidade</th>
          <th>Empresa</th>
          <th>Total $</th>
          <th>Percentual (%)</th>
        </tr>'
					   
--------------------------------------------------------------------------------------------------------------
WHILE EXISTS (SELECT TOP 1 cd_controle FROM #resulHTML)
BEGIN
    SELECT TOP 1
      @id               = cd_controle,
      @html_geral = @html_geral +
        '<tr class="tamanho">
            <td style="text-align: left;">' + ISNULL(caption, '') + '</td>
            <td>' + cast(ISNULL(quantidade, '')as nvarchar(20)) + '</td>
            <td>' + ISNULL(tipoPedido, '') + '</td>
            <td>' + ISNULL(subcaption1, '')  + '</td>
            <td>' + ISNULL(resultado1, '') + '</td>
            <td>' + ISNULL(resultado2, '')+'</td>
            <td>' + cast(ISNULL(resultado, 0) as nvarchar(20)) +'</td>
			<td>' + cast(ISNULL(percentual, 0) as nvarchar(20)) +'</td>
        </tr>'
	 FROM #resulHTML
    DELETE FROM #resulHTML WHERE cd_controle = @id
END
--------------------------------------------------------------------------------------------------------------------




set @html_rodape =
    '</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
	</div>
	<div class="section-title" style="margin-top:10px ;">
      <p style="margin-bottom:10px ;">Total de Pedidos: '+cast(isnull(@vl_total,0) as nvarchar(20))+'</p>
      <p>Quantidade: '+cast(isnull(@qt_total,0)as nvarchar(20))+'</p>
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

select 'Diário de Comodato' AS pdfName,isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------
--select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go


------------------------------------------------------------------------------
--exec pr_egis_relatorio_diario_comodato 283,0,''
------------------------------------------------------------------------------

