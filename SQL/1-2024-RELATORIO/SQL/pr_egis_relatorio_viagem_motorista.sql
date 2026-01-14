IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_viagem_motorista' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_viagem_motorista

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_viagem_motorista
-------------------------------------------------------------------------------
--pr_egis_relatorio_viagem_motorista
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
create procedure pr_egis_relatorio_viagem_motorista
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
declare @cd_relatorio           int = 0  
declare @cd_parametro           int = 0
  
--Dados do Relat�rio---------------------------------------------------------------------------------  
  
     declare  
   @titulo                     varchar(200),  
   @logo                       varchar(400),     
   @nm_cor_empresa             varchar(20),  
   @nm_endereco_empresa       varchar(200) = '',  
   @cd_telefone_empresa     varchar(200) = '',  
   @nm_email_internet      varchar(200) = '',  
   @nm_cidade        varchar(200) = '',  
   @sg_estado        varchar(10)  = '',  
   @nm_fantasia_empresa     varchar(200) = '',  
   @numero         int = 0,  
   @dt_pedido        varchar(60) = '',  
   @cd_cep_empresa       varchar(20) = '',  
   @cd_cliente        int = 0,  
 --  @nm_fantasia_cliente       varchar(200) = '',  
   @cd_cnpj_cliente      varchar(30) = '',  
   @nm_razao_social_cliente varchar(200) = '',  
   @nm_cidade_cliente   varchar(200) = '',  
   @sg_estado_cliente   varchar(5) = '',  
   @cd_numero_endereco   varchar(20) = '',  
   @nm_condicao_pagamento  varchar(100) = '',  
   @ds_relatorio    varchar(8000) = '',  
   @subtitulo     varchar(40)   = '',  
   @footerTitle    varchar(200)  = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @cd_pais     int = 0,  
   @nm_pais     varchar(20) = '',  
   @cd_cnpj_empresa   varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',  
   @nm_dominio_internet  varchar(200) = ''  
  
  
  
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
  select @cd_parametro           = valor from #json where campo = 'cd_usuario'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'  
  select @dt_final               = valor from #json where campo = 'dt_final'  
  select @cd_documento           = valor from #json where campo = 'cd_documento_form  
'  
  
  
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
  @dt_inicial       = dt_inicial,    
  @dt_final         = dt_final  
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
  @nm_cor_empresa          = isnull(e.nm_cor_empresa,'#1976D2'),  
  @nm_endereco_empresa      = isnull(e.nm_endereco_empresa,''),  
  @cd_telefone_empresa     = isnull(e.cd_telefone_empresa,''),  
  @nm_email_internet        = isnull(e.nm_email_internet,''),  
  @nm_cidade        = isnull(c.nm_cidade,''),  
  @sg_estado        = isnull(es.sg_estado,''),  
  @nm_fantasia_empresa     = isnull(e.nm_fantasia_empresa,''),  
  @cd_cep_empresa       = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),  
  @cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),  
  @nm_pais     = ltrim(rtrim(isnull(p.sg_pais,''))),  
  @cd_cnpj_empresa   = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),  
  @cd_inscestadual_empresa =  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),  
  @nm_dominio_internet  =  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))  
        
 from egisadmin.dbo.empresa e with(nolock)  
 left outer join Estado es  with(nolock) on es.cd_estado = e.cd_estado  
 left outer join Cidade c  with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado  
 left outer join Pais p   with(nolock) on p.cd_pais = e.cd_pais  
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
           
            text-align: center;  
        }  

    @media print {
      .bloco-motorista {
         break-inside: avoid;
         margin-top: 10px;
      }
      .motorista,
      table {        
        break-after: avoid;
       
      }
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
  
------------------------------------------------------------------------------------------------------------  
    set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)  
  
      
    declare @cd_bandeira         int = 0    
    declare @cd_destino          int = 0    
    declare @cd_motorista        int = 0    
    declare @cd_veiculo          int = 0    
    declare @cd_tipo_combustivel int = 0    
  
    ---  
  
   -- exec pr_resumo_viagem_combustivel 10,'09/01/2025', '09/30/2025',0,0,0,0,0  
   --return
  
 create table #AuxComissao  
    ( cd_controle int,  
      nm_motorista varchar(80),
      nm_bandeira  varchar(80),
	  sg_bandeira  varchar(20),
	  WTotalViagem float,
      qt_viagem    float)  
    
    --set @dt_inicial = '09/01/2025'  
    --set @dt_final   = '09/30/2025'  
  
    insert into #AuxComissao  
    exec pr_resumo_viagem_combustivel 10,@dt_inicial, @dt_final,@cd_bandeira,@cd_destino,@cd_motorista,@cd_veiculo,@cd_tipo_combustivel  
 
  --select * from #ResumoViagem
  --return
	select 
	    max(cd_controle)  as cd_controle,
		nm_motorista      as nm_motorista,
		max(WTotalViagem) as WTotalViagem,
		nm_bandeira       as nm_bandeira,
		sg_bandeira       as sg_bandeira,
		max(qt_viagem)    as qt_viagem
		--sum(qt_viagem)    as qt_viagem_total,
		--sum(WTotalViagem) as WTotalViagemTotal
		into 
		#ViagemTanque

	from
		#AuxComissao 
	group by 
	nm_motorista,nm_bandeira,sg_bandeira
	order by nm_motorista,sg_bandeira
--select * from #ViagemTanque return

 --------------------------------------------------------------------------------------------------------------------------------------------- 
  select  
  identity(int,1,1) as cd_controle,
  sum(qt_viagem)  as qt_total_viagem,
  sum(WTotalViagem) as WTotalViagem,
  nm_bandeira       as nm_bandeira,
  sg_bandeira       as sg_bandeira
 
 into
  #TotalBandeira
 
 from #AuxComissao 

  group by 
  nm_bandeira,sg_bandeira


  declare 
  @qt_total_viagem_final float = 0,
  @vl_total_litros       decimal = 0

  select 
	@qt_total_viagem_final = sum(qt_total_viagem),
	@vl_total_litros       = sum(WTotalViagem)
  from #TotalBandeira

--------------------------------------------------------------------------------------------------------------  
-- if isnull(@cd_parametro,0) = 1    
-- begin    
--    select * from #ViagemTanque  
--    order by  
--     nm_motorista, qt_viagem desc  
--    return    
-- end    

 --------------------------------------------------------------------------------------------------------------  
set @html_geral = '<div class="section-title">    
                        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>     
                        <p style="display: inline; text-align: center; padding: 15%;">'+isnull(@titulo,'')+'</p>    
                    </div>'
DECLARE 
  @nm_motorista VARCHAR(100),
  @nm_bandeira VARCHAR(100),
  @qt_viagem float,
  @WTotalViagem Decimal,
  @id INT,
  @totalWTotalViagem float,
  @qt_viagem_total float,
  @sg_bandeira varchar(20),
  @sg_bandeira_atual varchar(20),
  @sg_bandeira_anterior varchar(20),
  @sg_bandeira_soma float = 0, 
  @nm_motorista_anterior varchar(100) = '',
  @sg_bandeira_litros float = 0


WHILE EXISTS (SELECT 1 FROM #ViagemTanque)
BEGIN

    SELECT TOP 1
        @nm_motorista = nm_motorista,
		@qt_viagem_total = sum(qt_viagem),
        @totalWTotalViagem = sum(WTotalViagem)
    FROM #ViagemTanque
	group by 
	nm_motorista
    ORDER BY nm_motorista

    SET @html_geral = @html_geral + '
	<div class="bloco-motorista">
    <div class="section-title">
        <p class="motorista" style="font-weight:bold; font-size:16px;">' + ISNULL(@nm_motorista,'') + '</p>
    </div>
    <table>
        <tr style="background-color:#f0f0f0;">
            <th>Bandeira</th>
            <th>Qtd. Viagens</th>
            <th>Litros</th>
        </tr>'

	
    WHILE EXISTS (SELECT 1 FROM #ViagemTanque WHERE nm_motorista = @nm_motorista)
    BEGIN
        SELECT TOP 1
            @id = cd_controle,
            @nm_bandeira = nm_bandeira,
			@sg_bandeira = sg_bandeira,
            @qt_viagem = qt_viagem,
            @WTotalViagem = WTotalViagem,
			@sg_bandeira_atual = sg_bandeira
			

        FROM #ViagemTanque
        WHERE nm_motorista = @nm_motorista
        ORDER BY sg_bandeira
		
		
		if isnull(@sg_bandeira_atual,'') = @sg_bandeira_anterior
		begin
			set @sg_bandeira_soma = @sg_bandeira_soma + @qt_viagem
			set @sg_bandeira_litros = @sg_bandeira_litros + @WTotalViagem
	    end
	    else if ISNULL(@sg_bandeira_anterior,'') = ''
		begin
		    set @sg_bandeira_anterior = isnull(@sg_bandeira_atual,'')
			set @sg_bandeira_soma = @sg_bandeira_soma + @qt_viagem
			set @sg_bandeira_litros = @sg_bandeira_litros + @WTotalViagem
	    end
		else 
		begin 
			 SET @html_geral = @html_geral +  '
		      <tr style="font-weight: bold;font-size: 18px;">
		          <td style="text-align:center;">Total '+isnull(@sg_bandeira_anterior,'')+'</td>
		          <td style="text-align:center;">' + CAST(ISNULL(@sg_bandeira_soma,0) AS NVARCHAR(20)) + '</td>
		  		  <td style="text-align:center;">' + FORMAT(ISNULL(@sg_bandeira_litros, 0), 'N0', 'pt-BR') + '</td>
		      </tr>'
			set @sg_bandeira_soma = 0 
			set @sg_bandeira_soma = @sg_bandeira_soma + @qt_viagem
			set @sg_bandeira_litros = 0
			set @sg_bandeira_litros = @sg_bandeira_litros + @WTotalViagem
		    set @sg_bandeira_anterior = isnull(@sg_bandeira_atual,'')
		end

        SET @html_geral = @html_geral +  '
        <tr>
            <td style="text-align:left;">' + ISNULL(@nm_bandeira,'') + '</td>
            <td style="text-align:center;">' + CAST(ISNULL(@qt_viagem,0) AS NVARCHAR(20)) + '</td>
			<td style="text-align:center;">' + FORMAT(ISNULL(@WTotalViagem, 0), 'N0', 'pt-BR') + '</td>
        </tr>'

        DELETE FROM #ViagemTanque WHERE cd_controle = @id
    END
	
	SET @html_geral = @html_geral +  '
		     <tr style="font-weight: bold;font-size: 18px;">
		          <td style="text-align:center;">Total '+isnull(@sg_bandeira_anterior,'')+'</td>
		          <td style="text-align:center;">' + CAST(ISNULL(@sg_bandeira_soma,0) AS NVARCHAR(20)) + '</td>
		  		  <td style="text-align:center;">' + FORMAT(ISNULL(@sg_bandeira_litros, 0), 'N0', 'pt-BR') + '</td>
		     </tr>'
	set @sg_bandeira_soma = 0
	set @sg_bandeira_litros = 0
	set @sg_bandeira_anterior = ''

   SET @html_geral = @html_geral + 
        '<tr style="font-weight:bold; background-color:#e0e0e0;">
            <td style="text-align:right;">Total de Viagens:</td>
            <td>' + CAST(ISNULL(@qt_viagem_total,0) AS NVARCHAR(20)) + '</td>
            <td class="tamanho">' + FORMAT(ISNULL(@totalWTotalViagem, 0), 'N0', 'pt-BR') + '</td>
        </tr></table><br>
		</div>'

END
--------------------------------------------------------------------------------------------------------------------  
declare 
@sg_bandeira_total_viagem  float = 0,
@sg_bandeira_total_litros float = 0

set @html_geral = @html_geral + '
	</table> 
	<table>
		<tr style="font-weight: bold;font-size: 20px;">
			 <td class="tamanho">Bandeira</td> 
			 <td class="tamanho">Viagens</td> 
             <td class="tamanho">Litros</td>             
		</tr>' 
 
while exists ( select top 1 cd_controle from #TotalBandeira)
begin
	select top 1 
	@id                = cd_controle,
	@nm_bandeira       = nm_bandeira,
	@qt_viagem         = qt_total_viagem,
	@WTotalViagem      = WTotalViagem,
	@sg_bandeira_atual = sg_bandeira

  from #TotalBandeira 
	 order by sg_bandeira
	
		if isnull(@sg_bandeira_atual,'') = @sg_bandeira_anterior
		begin
			set @sg_bandeira_soma = @sg_bandeira_soma + @qt_viagem
			set @sg_bandeira_litros = @sg_bandeira_litros + @WTotalViagem
	    end
	    else if ISNULL(@sg_bandeira_anterior,'') = ''
		begin
		    set @sg_bandeira_anterior = isnull(@sg_bandeira_atual,'')
			set @sg_bandeira_soma = @sg_bandeira_soma + @qt_viagem
			set @sg_bandeira_litros = @sg_bandeira_litros + @WTotalViagem
	    end
		else 
		begin 
			 SET @html_geral = @html_geral +  '
		      <tr style="font-weight: bold;font-size: 18px;">
		          <td style="text-align:center;">Total '+isnull(@sg_bandeira_anterior,'')+'</td>
		          <td style="text-align:center;">' + CAST(ISNULL(@sg_bandeira_soma,0) AS NVARCHAR(20)) + '</td>
		  		  <td style="text-align:center;">' + FORMAT(ISNULL(@sg_bandeira_litros, 0), 'N0', 'pt-BR') + '</td>
		      </tr>'
			set @sg_bandeira_soma = 0 
			set @sg_bandeira_soma = @sg_bandeira_soma + @qt_viagem
			set @sg_bandeira_litros = 0
			set @sg_bandeira_litros = @sg_bandeira_litros + @WTotalViagem
		    set @sg_bandeira_anterior = isnull(@sg_bandeira_atual,'')
		end

        SET @html_geral = @html_geral +  '
        <tr>
            <td style="text-align:left;">' + ISNULL(@nm_bandeira,'') + '</td>
            <td style="text-align:center;">' + CAST(ISNULL(@qt_viagem,0) AS NVARCHAR(20)) + '</td>
			<td style="text-align:center;">' + FORMAT(ISNULL(@WTotalViagem, 0), 'N0', 'pt-BR') + '</td>
        </tr>'
  delete from #TotalBandeira where cd_controle = @id  
 end  
 SET @html_geral = @html_geral +  '
		     <tr style="font-weight: bold;font-size: 18px;">
		          <td style="text-align:center;">Total '+isnull(@sg_bandeira_anterior,'')+'</td>
		          <td style="text-align:center;">' + CAST(ISNULL(@sg_bandeira_soma,0) AS NVARCHAR(20)) + '</td>
		  		  <td style="text-align:center;">' + FORMAT(ISNULL(@sg_bandeira_litros, 0), 'N0', 'pt-BR') + '</td>
		     </tr>'
	set @sg_bandeira_soma = 0
	set @sg_bandeira_litros = 0
	set @sg_bandeira_anterior = ''

set @html_rodape =
'<tr  style="font-weight: bold;font-size: 18px;">
	<td>Total Geral</td>
	<td class="tamanho">'+cast(isnull(@qt_total_viagem_final,0) as nvarchar(20))+'</td> 
	<td class="tamanho">' + FORMAT(ISNULL(@vl_total_litros, 0), 'N0', 'pt-BR') + '</td>

</tr>
</table>  
 <div class="company-info">  
  <p><strong>'+@footerTitle+'</strong></p>  
 </div>  
  
    <p>'+@ds_relatorio+'</p>  
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
--exec pr_egis_relatorio_viagem_motorista '[{"cd_usuario":1,"cd_empresa":297,"cd_relatorio":390,"dt_inicial":"09-01-2025","dt_final":"09-30-2025"}]'
------------------------------------------------------------------------------
