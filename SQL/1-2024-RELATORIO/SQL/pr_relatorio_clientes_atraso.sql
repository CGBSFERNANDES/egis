IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_clientes_atraso' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_clientes_atraso

GO

---------------------------------------------------------------------------
create procedure pr_relatorio_clientes_atraso
@cd_relatorio          int   = 0,
@cd_usuario            int   = 0


as

declare @cd_empresa              int = 0
declare @dt_inicial_user		 date
declare @dt_final_user           date 
declare @dt_inicio				 date 
declare @data_hota_atual         nvarchar(30)
declare @cd_vendedor             int = 0
declare @dt_hoje                 nvarchar(50)
declare @dt_titulo               nvarchar(50)
declare @cd_ano                  int    
declare @cd_mes                  int    
declare @cd_dia                  int
declare @dt_inicial              datetime
declare @dt_final                datetime
declare @cd_grupo_relatorio      int
declare @dt_impresso             varchar (30)
declare @data_hora_atual_user    nvarchar(50) 



set @cd_vendedor = dbo.fn_usuario_vendedor(@cd_usuario)
set @cd_vendedor = isnull(@cd_vendedor,0)
------------------------------------------------------------------------------
-------------------Dados do Relat?rio---------------------------------------------------------------------------------

declare
    @dt_entrega                 nvarchar(50),
    @cd_pedido_venda            int      =    0,
	@cd_item					nvarchar(50),
	@logo                       varchar(400),			
	@nm_cor_empresa             varchar(20),
	@nm_endereco_empresa  	    varchar(200) = '',
	@cd_telefone_empresa    	varchar(200) = '',
	@nm_email_internet		    varchar(200) = '',
	@nm_cidade				    varchar(200) = '',
	@sg_estado				    varchar(10)	 = '',
	@nm_fantasia_empresa	    varchar(200) = '',
	@cd_cep_empresa			    varchar(20) = '',
	@cd_numero_endereco_empresa varchar(20)	  = '',
	@nm_pais					varchar(20) = '',
    @cd_cnpj_empresa			varchar(60) = '',
	@cd_inscestadual_empresa    varchar(100) = '',
	@nm_dominio_internet		varchar(200) = '',
	@titulo                     varchar(200)

------------------------------------------------------------------
/*--set @cd_pedido_venda = @cd_documento

declare @ds_minuta          varchar(8000)      
      
select @ds_minuta = isnull(ds_minuta,'')      
from      
 Parametro_Logistica   
--set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)       
--set @cd_empresa        = 0
set @dt_impresso       = cast(replace(convert(char,getdate(),103),'.','-') as varchar(30))        
*/
------------------------------------------------------------------------------

--if @json<>''
--begin
--  select                     
--    1                                                    as id_registro,
--    IDENTITY(int,1,1)                                    as id,
--    valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
--    valores.[value]              as valor                    
                    
--    into #json                    
--    from                
--      openjson(@json)root                    
--      cross apply openjson(root.value) as valores   

	  
------------------------------------------------------------------------------

  --set @dt_hoje            = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
  --select @dt_final_user   =  valor from #json where campo = 'dt_final_user'
  --select @dt_inicial_user =  valor from #json where campo = 'dt_inicial_user'
  
  --end
------------------------------------------------------------------------------
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)   
declare @ic_processo char(1) = 'N'
 

select
  @titulo             = nm_relatorio,
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)
from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio
-------------------------------------------------------------------------------
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

set @cd_empresa = dbo.fn_empresa()
-----------------------------------------------------------------------------------------
select 
		@logo                       = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),
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
--------------------------------------------------------------------------------------------------------------------------------------------
--Dados do Relat?rio
---------------------------------------------------------------------------------------------------------------------------------------------
 
declare @html            nvarchar(max) = '' --Total
declare @html_empresa    nvarchar(max) = '' --Cabe?alho da Empresa
declare @html_grafico    nvarchar(max) = '' --Gr?fico
declare @html_titulo     nvarchar(max) = '' --T?tulo
declare @html_detalhe_1  nvarchar(max) = '' -- Detalhes_1
declare @html_cab_det    nvarchar(max) = '' --Cabe?alho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_rod_det    nvarchar(max) = '' --Rodap? do Detalhe
declare @html_rodape     nvarchar(max) = '' --Rodape
declare @html_totais     nvarchar(max) = '' --Totais
declare @html_geral      nvarchar(max) = '' --Geral
declare @titulo_total    varchar(500)  = ''

set @html         = ''
set @html_empresa = ''
set @html_grafico = ''
set @html_titulo  = ''
set @html_cab_det = ''
set @html_detalhe = ''
set @html_rod_det = ''
set @html_rodape  = ''

-- Obt?m a data e hora atual
--set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
----------------------------------------------------------------------------------------------------
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
            padding: 5px;
            width: 30px;
            height: 30px;
            height: 55px;
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
        }

        img {
            max-width:200px;
            margin: 15px;
        }

        .company-info {
            text-align: right;
            margin-bottom: 10px;
        }

        .title {
            color: #1976D2;
        }

        p {
            margin: 5px;
            padding: 0;
        }

		.tabela1 {
        font-size: 15px;
        text-align: center;
        width: 15%;
      }
      .tabela2{
        font-size: 15px;
        text-align: center;
        width: 45%;
      }
      .tabela3{
        font-size: 15px;
        text-align: center;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
    </style>
</head>
<body>
   
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:20%; margin-right:20px">
			<img src="'+@logo+'" alt="Logo da Empresa">
		</div>
		<div style="width:70%; padding-left:10px">
			<p class="title">'+@nm_fantasia_empresa+'</p>
		    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
		    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
		    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
		</div>    
    </div>'

------------------------------------------------------------------------------------------------------------------------------------------------
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
  
 --------------------------------------------------------------------------------------------------------------------------------------
 
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


--------------------------------------------------------------------------------------------------------------------------
declare @ic_codigo_cliente nvarchar(10)
select
  dr.cd_cliente,
  count(distinct dr.cd_cliente)                                                                                 as qt_cliente,
  SUM( 
  cast(str(isnull(dr.vl_saldo_documento,0 ) -  isnull(dr.vl_abatimento_documento,0),25,2) as decimal(25,2))
  )                                                                                                              as 'Total_Atraso',


  min(convert(datetime, dr.dt_vencimento_documento, 103))                                                        as 'Vencimento',
  count(dr.cd_vendedor)                                                                                          as 'qt_vendedor',
  COUNT(distinct dr.cd_documento_receber)                                                                        as qt_documento,
  MAX(cli.nm_razao_social_cliente)                                                                               as nm_razao_social_cliente,
  MAX(cli.nm_fantasia_cliente)                                                                                   as nm_fantasia_cliente,
  MAX(v.nm_fantasia_vendedor)                                                                                    as nm_fantasia_vendedor,
  MIN(dr.dt_vencimento_documento)                                                                                as dt_vencimento,
  max(p.nm_portador)                                                                                             as nm_portador

into
	#Tabela_aux
	
from
   Documento_Receber dr               with (nolock) 
   left outer join cliente cli 		  with (nolock)	on cli.cd_cliente       = dr.cd_cliente   
   left outer join status_cliente sc  with (nolock) on sc.cd_status_cliente = cli.cd_status_cliente  
   left outer join cliente_grupo cg   with (nolock) on cli.cd_cliente_grupo = cg.cd_cliente_grupo 
   left outer join Vendedor v         with (nolock) on v.cd_vendedor        = cli.cd_vendedor       
   left outer join vw_destinatario vw with (nolock) on vw.cd_destinatario = dr.cd_cliente and
                                        			   vw.cd_tipo_destinatario = dr.cd_tipo_destinatario
   left outer join tipo_cobranca tc   with (nolock) on tc.cd_tipo_cobranca = dr.cd_tipo_cobranca 
   left outer join Portador p         with (nolock) on p.cd_portador       = dr.cd_portador
   
where
   dr.dt_vencimento_documento <= dbo.fn_dia_util (getdate()-1,'N','U') and
   CAST(isnull(dr.vl_saldo_documento,0) - isnull(dr.vl_abatimento_documento,0) AS DECIMAL(25,2)) > 0.001 AND  dr.dt_cancelamento_documento is null and dr.dt_devolucao_documento is null
   and isnull(dr.cd_tipo_destinatario,1)=1
   and isnull(dr.cd_vendedor,0)          = case when @cd_vendedor = 0 then isnull(dr.cd_vendedor,0) else @cd_vendedor end
   and cli.cd_status_cliente = 1
   and isnull(sc.ic_analise_status_cliente,'N')='S'  

 group by
   dr.cd_cliente
   

declare @qt_cliente      int
declare @vl_total_atraso decimal(25,2)

declare @qt_documento    int
declare @pc_atraso       float

set @qt_cliente      = 0
set @vl_total_atraso = 0
set @qt_documento    = 0

select
  @qt_cliente      = COUNT(qt_cliente),
  @qt_documento    = COUNT(qt_documento),
  @vl_total_atraso = SUM(Total_Atraso)
from
  #Tabela_aux

 
 ------------------------------------------------------------------------------------------------------------------------------------------------------------
 --Consulta geral dos clientes em atraso
 ------------------------------------------------------------------------------------------------------------------------------------------------------------

 select top 150
    identity(int,1,1)                                                  as cd_controle,
   
	 ' R$ '+dbo.fn_formata_valor(@vl_total_atraso)      as 'titleHeader',
	cast(qt_documento as varchar(6))                                       as 'badgeTitle',
	cast(@qt_cliente as varchar)                         as 'subtitleHeader', 
	CAST('cash' as varchar(30))                                            as 'iconHeader', 
	CAST('' as varchar(150))                                               as 'imageHeader',
	CAST('' as varchar(80))                                                as 'subtitle2Header',	
	'cursor-default-click'                                                 as 'iconFooter1',
    'account-circle'                                                       as 'iconFooter2',
    ltrim(rtrim(nm_fantasia_cliente))                                      as 'searchLabel',
	isnull(ltrim(rtrim(nm_fantasia_cliente)),'') + 
	case when @ic_codigo_cliente = 'S'
	     then '('+CAST(cd_cliente as varchar)+')'
	     else ''
	end                                                                     as 'caption',
	''+ltrim(rtrim(nm_fantasia_vendedor))                                   as 'subcaption1',
	isnull(cd_cliente,0)                                                    as cd_cliente,
	CAST('' as varchar(1))                                                  as 'quantidade',
	'R$ ' +dbo.fn_formata_valor(Total_Atraso) +
	case when isnull(Total_Atraso,0) > 0 and isnull(nm_portador,'') <> ''
	     then ' - ' 
		 else ''
	end	+
	case when isnull(nm_portador,'') <> ''
	     then ltrim(rtrim(nm_portador))
		 else ''
	end                                                                                 as 'resultado',
	'S'																					as ic_sub_menu,
   cast(cast(Total_Atraso / @vl_total_atraso * 100 as decimal(10, 2)) as varchar(10))   as 'percentual'

into #tabela
from
   #Tabela_aux

where
  isnull(total_atraso,0)>0 

order by
   Total_Atraso desc
----------------------------------------------------------------------------------------------------
set @data_hora_atual_user = convert(nvarchar, getdate(), 103) + ' AS ' + convert(nvarchar, getdate(), 108)
 
declare @nm_cliente          nvarchar(100)
declare @ds_resultado		 nvarchar(50)
declare @percentual          nvarchar(20)
declare @nm_vendedor         nvarchar(4000)
declare @ds_total_cliente    nvarchar(50)
declare @ds_qt_cliente       nvarchar(50)

select 
	@ds_total_cliente            = titleHeader,
	@ds_qt_cliente               = subtitleHeader
from 
	#tabela
-------------------------------------------------------------------------------------------------------------------------
declare @verifica nvarchar(10)

	SELECT 
		@verifica = ic_codigo_cliente
	from config_egismob

-------------------------------------------------------------------------------------------------------------------------
if @cd_vendedor > 0
begin
  set @nm_vendedor = (select top 1 nm_fantasia_vendedor from Vendedor where cd_vendedor = @cd_vendedor)
  set @nm_vendedor = isnull(@nm_vendedor,'')
end
--------------------------------------------------------------------------------------------------------------------------

set @html_detalhe = 
	'<div>
        <h2 style="display: flex; justify-content: center; align-items: center; color: #1976D2;">RELATÓRIO POR CLIENTES EM ATRASO</h2>
	'
	+ case when isnull(@cd_vendedor,0) > 0
	       then 
	'<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; font-size: 20px;">
		<p><strong> Vendedor: </strong>'+isnull(@nm_vendedor,'')+' </p>
    </div>'
	else ''
	   end +
    '<div>
        <p class="section-title"><strong>CLIENTES</strong></p>    
     </div>
        <table>
            <thead>
                <tr>
                    <th>ITEM</th>
                    <th>NOME</th>
                    <th>VALOR</th>
                    <th>PERCENTUAL (%)</th>
                </tr>
            </thead>'

 ------------------------------------------------------------------------------------------------------
 
 declare @id int = 0
	while exists ( select top 1 cd_controle from #tabela)
	begin

  select top 1
    @id            = cd_controle,
	@ds_resultado =  resultado,
	@percentual   =  percentual
from #tabela 


if @verifica = 'S'
begin
	set @nm_cliente   = (select top 1 isnull(searchLabel,'') + ' ' + '(' + cast(cd_cliente as varchar) + ')' from #Tabela)
End
else 
begin
	set @nm_cliente   = (select top 1 isnull(searchLabel,'') from #Tabela)
end

    set @html_detalhe = @html_detalhe + '
           <tbody>
                <tr>
                    <td class="tabela1">'+cast(isnull(@id,0)as nvarchar(20))+'</td>
                    <td class="tabela2">'+isnull(@nm_cliente,'')+'</td>
                    <td class="tabela3">'+isnull(@ds_resultado,'')+'</td>
                    <td class="tabela1">'+isnull(@percentual,'')+'</td>
                </tr>
            </tbody>'

  
  delete from #tabela where cd_controle = @id

  
end

-------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
  SET @html_rodape =
		'</table>	   
		 <div>
			<p class="section-title"><strong>TOTAL</strong></p>    
		 </div>
		 <div>
            <p><strong>Total em atraso: </strong>'+isnull(@ds_total_cliente,'')+'</p>
         </div>

         <div>
            <p><STRONg>Quantidade total: </strong>'+isnull(@ds_qt_cliente,'')+'</p>
	     </div>
		<div>
            <p style="font-size: 25px;text-align: center;margin-top: 3%; color: red;">Para consulta detalhada de clientes em atraso verifique o sistema.</p>
        </div>
		<div style="text-align: right; margin-top: 3%; width: 100%;">
			<p>Gerado em: '+cast(isnull(@data_hora_atual_user,0) as nvarchar(50))+'</p>
		</div>
		</div>'
--HTML Completo--------------------------------------------------------------------------------------


set @html         = 
    @html_empresa +
    @html_titulo  +

	--@html_cab_det +
	 @html_detalhe +
	 @html_detalhe_1 +
	--@html_rod_det +
	@html_geral   + 
	@html_totais  +
	@html_grafico +
    @html_rodape  

--select @html, @html_empresa, @html_titulo, @html_cab_det, @html_rod_det, @html_totais, @html_grafico, @html_rodape

-------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------


go

--exec pr_relatorio_clientes_atraso 210,4253