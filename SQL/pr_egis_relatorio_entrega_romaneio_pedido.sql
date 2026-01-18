IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_entrega_romaneio_pedido' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_entrega_romaneio_pedido

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_entrega_romaneio_pedido  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_entrega_romaneio_pedido
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
create procedure pr_egis_relatorio_entrega_romaneio_pedido 
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
declare @cd_cliente             int = 0 
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
  
--select * from #json  
  
-------------------------------------------------------------------------------------------------  
  
  select @cd_empresa             = valor from #json where campo = 'cd_empresa'               
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'               
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'  
  select @dt_final               = valor from #json where campo = 'dt_final'   
  select @cd_veiculo             = valor from #json where campo = 'cd_veiculo' 
  select @cd_entregador			 = valor from #json where campo = 'cd_entregador'
  SELECT @ic_imagem              = Valor from #json where campo = 'ic_imagem'
  select @cd_cliente             = Valor from #json where campo = 'cd_cliente'


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
	@cd_veiculo   		  = isnull(cd_veiculo,0),   
	@cd_entregador        = isnull(cd_entregador,0),
	@cd_cliente           = isnull(cd_cliente,0)
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
    
--SELECT @nm_dados_cab_det    
    
drop table #AuxRelAtributo    
---------------------------------------------------------------------------------------------------------------    
    
if isnull(@cd_parametro,0) = 2    
 begin    
  select * from #RelAtributo    
  return    
end    

--set @dt_inicial = '04/01/2025'
--set @dt_final = '04/01/2025'
--set @cd_veiculo = 0   
--set	@cd_entregador = 0
--set	@ic_imagem = 2

--select * from  romaneio where cd_romaneio = 22268
---------------------------------------------------------------------------------------------------------------
select 
    IDENTITY(int,1,1)           as cd_controle,
	ro.cd_romaneio              as cd_romaneio,
	ro.dt_entrega_romaneio      as dt_entrega_romaneio,
	ro.hr_entrega               as hr_entrega,
	c.cd_cliente                as cd_cliente,
	c.nm_fantasia_cliente       as nm_fantasia_cliente,
	c.nm_razao_social_cliente   as nm_razao_social_cliente,
	c.cd_cnpj_cliente           as cd_cnpj_cliente,
	e.nm_entregador             as nm_entregador,
	v.cd_veiculo                as cd_veiculo,
	v.nm_veiculo                as nm_veiculo,
	rd.nm_ftp_comprovante       as nm_ftp_comprovante,
	rd.nm_ftp_assinatura        as nm_ftp_assinatura,
	rd.vb_comprovante           as vb_comprovante,
	rd.vb_assinatura            as vb_assinatura,
	re.nm_responsavel           as nm_responsavel,
	re.nm_documento_responsavel as nm_documento_responsavel

	into
	#RomaneioRel
from 
 romaneio ro
 left outer join cliente c             on c.cd_cliente            = ro.cd_cliente
 left outer join entregador e          on e.cd_entregador         = ro.cd_entregador
 left outer join veiculo v             on v.cd_veiculo            = ro.cd_veiculo 
 left outer join Romaneio_Documento rd on rd.cd_romaneio          = ro.cd_romaneio 
 left outer join Romaneio_Entrega re   on re.cd_romaneio          = ro.cd_romaneio 

 where 
 --ro.cd_romaneio between 57 and 81-- between 22385 and 22374
 ro.dt_romaneio between @dt_inicial and @dt_final 
 and 
 e.cd_entregador = case when isnull(@cd_entregador,0) = 0 then e.cd_entregador else isnull(@cd_entregador,0) end
 and 
 isnull(v.cd_veiculo,0) = case when isnull(@cd_veiculo,0) = 0 then isnull(v.cd_veiculo,0) else isnull(@cd_veiculo,0) end
 and 
 ro.cd_cliente = case when isnull(@cd_cliente,0) = 0 then isnull(ro.cd_cliente,0) else isnull(@cd_cliente,0) end 

 --select * from romaneio        
---------------------------------------------------------------------------------------------------------------
if isnull(@cd_parametro,0) = 1    
 begin    
  select * from #RomaneioRel    
  return    
end    
--------------------------------------------------------------------------------------------------------------  
declare @nm_ftp_comprovante  nvarchar(max)
declare @nm_ftp_assinatura  nvarchar(max)
declare @img_comprovante VARBINARY(max)
declare @img_assinatura  VARBINARY(max)

--------------------------------------------------------------------------------------------------------------

set @html_geral = '  
     <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 21%;">'+isnull(@titulo,'')+'</p>  
    </div>  
	'
	
--------------------------------------------------------------------------------------------------------------     
	
while exists( select Top 1 cd_controle from #RomaneioRel )
  begin
	
  select top 1   
      @id                      = cd_controle,
	  @nm_ftp_comprovante      = nm_ftp_comprovante,

	  @html_cab_det = @html_cab_det +

		'
		<table class="tamanho">
		<tr>
			<th>Data Entrega</th>
			<th>Romaneio</th>
			<th>Hora</th>
			<th>Código</th>
			<th>Cliente</th>
			<th>Razão Social</th>
			<th>CNPJ</th>
			<th>Entregador</th>
			<th>Veículo</th>
			<th>Responsável</th>
			<th>Documento</th>		
		</tr>
		<tr class="tamanho">	
		    <td>'+cast(isnull(cd_romaneio,0)as varchar(20))+'</td> 
			<td>'+isnull(dbo.fn_data_string(dt_entrega_romaneio),'')+'</td>
			<td>'+isnull(hr_entrega,'')+'</td>
			<td>'+cast(isnull(cd_cliente,0) as varchar(20))+'</td>
			<td>'+isnull(nm_fantasia_cliente,'')+'</td>
			<td>'+isnull(nm_razao_social_cliente,'')+'</td>
			<td>'+isnull(dbo.fn_formata_cnpj(cd_cnpj_cliente),'')+'</td>
			<td>'+isnull(nm_entregador,'')+'</td>	
			<td>'+isnull(nm_veiculo,'')+'</td>	
			<td>'+isnull(nm_responsavel,'')+'</td>
			<td>'+isnull(nm_documento_responsavel,'')+'</td>
	    </tr>
	
	'+case when isnull(@ic_imagem,1) <> 2 then ' 
	</table>
	<table style="margin:10px; text-align: center;">
		
		<tr id="'+ISNULL(@nm_ftp_comprovante,'')+'" style="display: flex; justify-content: center; align-items: center; gap: 20px;">  
	'+ case when r.vb_comprovante is not null then
		' <img src="data:image/jpeg;base64,' + ISNULL( CAST('' AS XML).value('xs:base64Binary(sql:column("r.vb_comprovante"))', 'VARCHAR(MAX)'), '') + '" alt="Comprovante" style="max-width:150px;">'
	else ''
		end +'
		'+ case when r.vb_assinatura is not null then
		 
		 ' <img src="data:image/jpeg;base64,' + ISNULL( CAST('' AS XML).value('xs:base64Binary(sql:column("r.vb_assinatura"))', 'VARCHAR(MAX)') , '') + '" alt="Assinatura" style="max-width:150px;">'
	   
		else ''
		end +'
		</tr>
<script>
            async function carregarImagens() {
  try {
    
    const links = [
      '+ case when ISNULL(nm_ftp_comprovante,'') = '' then '' else '"https://egis-store.com.br/api/download/'+ISNULL(nm_ftp_comprovante, '')+'/'+ISNULL(@nm_ftp_empresa,'')+'/RomaneioDocumento",' end +'
      '+ case when ISNULL(nm_ftp_assinatura,'') = '' then '' else '"https://egis-store.com.br/api/download/'+ISNULL(nm_ftp_assinatura, '')+'/'+ISNULL(@nm_ftp_empresa,'')+'/RomaneioDocumento"' end +'
    ];

    const listaImagens = document.getElementById("'+ISNULL(@nm_ftp_comprovante,'')+'");

    for (let link of links) {
      const response = await fetch(link, { method: "GET" });
      if (!response.ok) {
        throw new Error("Erro ao buscar imagem: " + response.status);
      }

      const blob = await response.blob();
      const urlImagem = URL.createObjectURL(blob);

      const img = document.createElement("img");
      img.src = urlImagem;
      img.alt = "Comprovante";
      img.style.width = "200px";
      img.style.margin = "10px";

      listaImagens.appendChild(img);
    }
  } catch (erro) {
    console.error("Erro ao carregar imagens:", erro);
  }
}


carregarImagens();
</script>'
  else
  ''
  end+''
     from #RomaneioRel as r
	 DELETE FROM #RomaneioRel WHERE cd_controle = @id

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
  
--exec pr_egis_relatorio_entrega_romaneio_pedido 291,0,''
--select * from veiculo
