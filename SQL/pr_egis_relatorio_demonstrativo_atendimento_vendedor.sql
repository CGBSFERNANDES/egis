IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_demonstrativo_atendimento_vendedor' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_demonstrativo_atendimento_vendedor

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_demonstrativo_atendimento_vendedor  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_demonstrativo_atendimento_vendedor
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
--Altera��o        :   
--  
--  
------------------------------------------------------------------------------  
create procedure pr_egis_relatorio_demonstrativo_atendimento_vendedor 
@cd_relatorio int   = 0,  
@cd_parametro int   = 0,  
@json nvarchar(max) = ''   
  

as  
  
set @json = isnull(@json,'')  
declare @data_grafico_bar       nvarchar(max)  
declare @cd_empresa             int = 0  
declare @cd_form                int = 0  
declare @cd_usuario             int = 0  
declare @cd_documento           int = 0  
declare @dt_hoje                datetime  
declare @dt_inicial             datetime  
declare @dt_final               datetime  
declare @cd_ano                 int      
declare @cd_mes                 int      
declare @cd_dia                 int  
declare @cd_grupo_relatorio     int = 0   
declare @id                     int = 0
declare @cd_vendedor            int = 0
--Dados do Relat�rio---------------------------------------------------------------------------------  
  
declare  
   @titulo                     varchar(200),  
   @logo                       varchar(400),     
   @nm_cor_empresa             varchar(20),  
   @nm_endereco_empresa        varchar(200) = '',  
   @cd_telefone_empresa        varchar(200) = '',  
   @nm_email_internet          varchar(200) = '',  
   @nm_cidade                  varchar(200) = '',  
   @sg_estado                  varchar(10)  = '',  
   @nm_fantasia_empresa        varchar(200) = '',  
   @numero                     int = 0,  
   @dt_pedido                  varchar(60) = '',  
   @cd_cep_empresa             varchar(20) = '',   
   @nm_cidade_cliente          varchar(200) = '',  
   @sg_estado_cliente          varchar(5) = '',  
   @cd_numero_endereco         varchar(20) = '',  
   @ds_relatorio               varchar(8000) = '',  
   @subtitulo                  varchar(40)   = '',  
   @footerTitle                varchar(200)  = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @cd_pais                    int = 0,  
   @nm_pais                    varchar(20) = '',  
   @cd_cnpj_empresa            varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',  
   @nm_dominio_internet        varchar(200) = '',
   @cd_romaneio                int = 0,
   @cd_veiculo                 int = 0,   
   @cd_entregador			   int = 0,
   @ic_imagem                  int = 0 
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
    @dt_inicial           = dt_inicial,    
    @dt_final             = dt_final,
	@cd_vendedor   		  = isnull(cd_vendedor,'')   
	--@cd_entregador        = isnull(nm_entregador,'')
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
--caminho ftp empresa
declare @nm_ftp_empresa nvarchar(80)
select @nm_ftp_empresa = nm_ftp_empresa from EGISADMIN.dbo.Empresa where cd_empresa = @cd_empresa 
 

 --Dados da empresa-----------------------------------------------------------  
  
 select   
  @logo                       = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),  
  @nm_cor_empresa             = isnull(e.nm_cor_empresa,'#1976D2'),  
  @nm_endereco_empresa        = isnull(e.nm_endereco_empresa,''),  
  @cd_telefone_empresa        = isnull(e.cd_telefone_empresa,''),  
  @nm_email_internet          = isnull(e.nm_email_internet,''),  
  @nm_cidade                  = isnull(c.nm_cidade,''),  
  @sg_estado                  = isnull(es.sg_estado,''),  
  @nm_fantasia_empresa        = isnull(e.nm_fantasia_empresa,''),  
  @cd_cep_empresa             = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),  
  @cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),  
  @nm_pais					  = ltrim(rtrim(isnull(p.sg_pais,''))),  
  @cd_cnpj_empresa            = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),  
  @cd_inscestadual_empresa    =  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),  
  @nm_dominio_internet        =  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))  
        
 from egisadmin.dbo.empresa e with(nolock)  
 left outer join Estado es    with(nolock) on es.cd_estado = e.cd_estado  
 left outer join Cidade c     with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado  
 left outer join Pais p       with(nolock) on p.cd_pais    = e.cd_pais  
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
    <title >'+isnull(@titulo,'')+'</title>  
    <style>  
        body {  
            font-family: Arial, sans-serif;  
            color: #333;  
            padding:20px;  
			flex:1;
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
			text-align: center;
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
            font-size:12px;
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
   
    
drop table #AuxRelAtributo    
---------------------------------------------------------------------------------------------------------------    
    
if isnull(@cd_parametro,0) = 2    
 begin    
  select * from #RelAtributo    
  return    
end    

--set @dt_inicial = '04/01/2025'
--set @dt_final = '04/30/2025'

---------------------------------------------------------------------------------------------------------------

select
  identity(int,1,1) as cd_controle, 
  c.cd_cliente,
  c.nm_fantasia_cliente as nm_fantasia_cliente,
  c.nm_razao_social_cliente as nm_razao_social_cliente,
  dbo.fn_formata_cnpj(c.cd_cnpj_cliente) AS cd_cnpj_cliente,
  c.nm_email_cliente as nm_email_cliente,
  c.cd_telefone as cd_telefone,
  v.cd_visita as cd_visita,

case 
  when isnull(vj.nm_obs_registro,'') = ''
    then case 
           when isnull(cast(vb.ds_baixa_visita as varchar(1000)),'') = ''
             then isnull(cast(v.ds_visita_retorno as varchar(1000)),'')
             else isnull(cast(vb.ds_baixa_visita as varchar(1000)),'')
         end
    else isnull(vj.nm_obs_registro,'')
end as nm_descricao_atendimento,
  vb.dt_baixa_visita              AS dt_baixa_visita,
  j.nm_justificativa              as nm_motivo,
  ve.cd_vendedor                   AS cd_vendedor,
  ve.nm_fantasia_vendedor          AS nm_fantasia_vendedor,
  est.sg_estado                   AS sg_estado,
  cid.nm_cidade                   AS nm_cidade
  into
  #atendimentoRel
from
  Visita v                                     with(nolock)
  left outer join Visita_Baixa vb              with(nolock) on vb.cd_visita       = v.cd_visita
  left outer join Visita_Justificativa vj      with(nolock) on vj.cd_visita       = v.cd_visita
  left outer join Justificativa_nao_compra j   with(nolock) on j.cd_justificativa = vj.cd_justificativa
  left outer join cliente c                                 on c.cd_cliente       = v.cd_cliente 
  left outer join vendedor ve                               on ve.cd_vendedor     = v.cd_vendedor 
  left outer join Pais pa                      WITH(NOLOCK) ON pa.cd_pais         = c.cd_pais
  left outer join Estado est                   WITH(NOLOCK) ON est.cd_pais        = pa.cd_pais AND est.cd_estado = c.cd_estado
  left outer join cidade cid                   WITH(NOLOCK) ON cid.cd_pais        = pa.cd_pais AND cid.cd_estado = est.cd_estado AND cid.cd_cidade = c.cd_cidade 

where
  v.dt_visita between @dt_inicial and @dt_final
  and v.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then v.cd_vendedor else isnull(@cd_vendedor,0) end
  and (
    @cd_empresa = 274
    or (
      @cd_empresa <> 274
      and (
        vb.cd_visita is not null
        or vj.cd_visita is not null
      )
    )
  )

 --  select * from #atendimentoRel
---------------------------------------------------------------------------------------------------------------
if isnull(@cd_parametro,0) = 1    
 begin    
  select * from #atendimentoRel    
  return    
end    
--------------------------------------------------------------------------------------------------------------  
set @html_geral = '  
     <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 21%;">'+isnull(@titulo,'')+'</p>  
    </div>  
	<table class="tamanho">
		<tr>
			<th>Data</th>
			<th>Tipo</th>
			<th>Motivo</th>
			<th>Vendedor</th>
			<th>Razão Social</th>
			<th>Nome Fantasia</th>
			<th>CNPJ</th>
			<th>Estado</th>
			<th>Cidade</th>
			<th>Email</th>
			<th>Telefone</th>		
			<th>Resultado Atendimento</th>
			<th>Descrição</th>
		<tr>'
--------------------------------------------------------------------------------------------------------------     
	
while exists( select Top 1 cd_controle from #atendimentoRel )
  begin

  select top 1   
      @id                      = cd_controle,
	  @html_cab_det = @html_cab_det +

		'<tr class="tamanho">	
			<td>'+isnull(dbo.fn_data_string(dt_baixa_visita),'')+'</td>
		    <td>'+isnull(tipo,'')+'</td> 			
			<td>'+isnull(nm_motivo,'')+'</td>
			<td>'+isnull(nm_fantasia_vendedor,'')+'</td>
			<td>'+isnull(nm_razao_social_cliente,'')+'</td>
			<td>'+isnull(nm_fantasia_cliente,'')+'</td>
			<td>'+isnull(cd_cnpj_cliente,'')+'</td>
			<td>'+isnull(sg_estado,'')+'</td>	
			<td>'+isnull(nm_cidade,'')+'</td>
			<td>'+isnull(nm_email_cliente,'')+'</td>
			<td>'+isnull(cd_telefone,'')+'</td>
			<td></td>
			<td>'+isnull(nm_descricao_atendimento,'')+'</td>
	    </tr>'

     from #atendimentoRel 

	 DELETE FROM #atendimentoRel WHERE cd_controle = @id

end

--------------------------------------------------------------------------------------------------------------------  
  
  
set @html_rodape ='
</table>
 <div class="report-date-time">  
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>  
    </div>  
 </body>  
 </html>
 '  
  
  
  
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
  
--exec pr_egis_relatorio_demonstrativo_atendimento_vendedor 291,0,''
