IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_cliente' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_cliente

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_relatorio_cliente  
-------------------------------------------------------------------------------  
--pr_relatorio_cliente  
-------------------------------------------------------------------------------  
--GBS Global Business Solution Ltda                                        2024  
-------------------------------------------------------------------------------  
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020  
--  
--Autor(es)        : Jo�o Pedro Mar�al  
--Banco de Dados   : Egissql - Banco do Cliente   
--  
--Objetivo         : Relat�rio Padr�o Egis HTML - EgisMob, EgisNet, Egis  
--Data             : 10.01.2025  
--Altera��o        :   
--  
--  
------------------------------------------------------------------------------  
create procedure pr_relatorio_cliente  
@json nvarchar(max) = ''   
  
  
as  
  
set @json = isnull(@json,'')  
declare @data_grafico_bar       nvarchar(max)  
declare @cd_empresa             int = 0  
declare @cd_form                int = 0  
declare @cd_usuario             int = 0  
declare @cd_documento           int = 0  
declare @cd_parametro           int = 0  
declare @dt_hoje                datetime  
declare @dt_inicial             datetime  
declare @dt_final               datetime  
declare @cd_ano                 int = 0     
declare @cd_mes                 int = 0     
declare @cd_dia                 int = 0 

set @dt_hoje = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)  
--Dados do Relat�rio---------------------------------------------------------------------------------  
  
  declare  
   @titulo                      varchar(200),  
   @logo                        varchar(400),     
   @nm_cor_empresa              varchar(20),  
   @nm_endereco_empresa         varchar(200) = '',  
   @cd_telefone_empresa         varchar(200) = '',  
   @nm_email_internet           varchar(200) = '',  
   @nm_cidade                   varchar(200) = '',  
   @sg_estado                   varchar(10)  = '',  
   @nm_fantasia_empresa         varchar(200) = '',  
   @numero                      int = 0,  
   @dt_pedido                   varchar(60) = '',  
   @cd_cep_empresa              varchar(20) = '',  
   @cd_cliente                  int = 0,   
   @cd_cnpj_cliente             varchar(30) = '',  
   @nm_razao_social_cliente     varchar(200) = '',  
   @nm_cidade_cliente           varchar(200) = '',  
   @sg_estado_cliente           varchar(5) = '',  
   @cd_numero_endereco          varchar(20) = '',  
   @nm_condicao_pagamento       varchar(100) = '',  
   @ds_relatorio                varchar(8000) = '',  
   @subtitulo                   varchar(40)   = '',  
   @footerTitle                 varchar(200)  = '',  
   @cd_numero_endereco_empresa  varchar(20)   = '',  
   @cd_pais                     int = 0,  
   @nm_pais                     varchar(20) = '',  
   @cd_cnpj_empresa             varchar(60) = '',  
   @cd_inscestadual_empresa     varchar(100) = '',  
   @nm_dominio_internet         varchar(200) = ''  ,
   @cd_relatorio                int = 0
  
 
           
set @cd_parametro      = 0  
set @cd_empresa        = 0  
set @cd_form           = 0  
set @cd_parametro      = 0  
set @cd_documento      = 0  
------------------------------------------------------------------------------------------------------  
  
if @json<>''  
begin  
  select                 
    identity(int,1,1)             as id,                 
    valores.[key]                 as campo,                 
    valores.[value]               as valor                
  into #json                
  from                 
    openjson(@json)root                
    cross apply openjson(root.value) as valores       
  

  
  select @cd_empresa             = valor from #json where campo = 'cd_empresa'               
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'               
  select @cd_documento           = valor from #json where campo = 'cd_documento'  
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'  
  select @cd_cliente             = valor from #json where campo = 'cd_cliente'  
  
   set @cd_documento = isnull(@cd_documento,0)  

end  
  
  
-------------------------------------------------------------------------------------------------  
declare @ic_processo char(1) = 'N'  
    
select  
  @titulo      = ltrim(rtrim(isnull(nm_relatorio,''))),  
  @ic_processo = isnull(ic_processo_relatorio, 'N')  
from  
  egisadmin.dbo.Relatorio  
where  
  cd_relatorio = @cd_relatorio  

  set @ic_processo = isnull(@ic_processo,'N')
  
----------------------------------------------------------------------------------------------------------------------------  
--Empresa  
----------------------------------  
set @cd_empresa = dbo.fn_empresa()  

  
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
  
-- Obt�m a data e hora atual  
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)  
------------------------------  
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
  

--------------------------------------------------------------------------------------------------------------------------  
  
select   
 ltrim(rtrim(isnull(c.nm_fantasia_cliente,'')))        as nm_fantasia_cliente,  
 ltrim(rtrim(isnull(c.nm_razao_social_cliente,'')))    as nm_razao_social_cliente,  
 c.nm_email_cliente                                    as nm_email_cliente,  
 c.dt_cadastro_cliente                                 as dt_cadastro_cliente,  
 case when c.cd_tipo_pessoa = 1 
      then dbo.fn_formata_cnpj(c.cd_cnpj_cliente)
      else dbo.fn_formata_cpf(c.cd_cnpj_cliente) 
 end                          as cd_cnpj_cliente,  
 c.cd_inscestadual            as cd_inscestadual,  
 c.cd_cep                     as cd_cep,  
 c.nm_complemento_endereco    as nm_complemento_endereco,  
 c.nm_endereco_cliente        as nm_endereco_cliente,  
 c.cd_numero_endereco         as cd_numero_endereco,  
 c.nm_bairro                  as nm_bairro,  
 ci.nm_cidade                 as nm_cidade,  
 e.nm_estado                  as nm_estado,  
 c.cd_telefone                as cd_telefone,  
 sm.nm_segmento_mercado       as nm_segmento_mercado,  
 r.nm_regiao                  as nm_regiao,  
 cp.ds_perfil_cliente         as ds_perfil_cliente,  
 cp.ds_perfil_entrega_cliente as ds_perfil_entrega_cliente, 
 cp.nm_restricao_entrega      as nm_restricao_entrega,
 case when cp.ic_seg_entrega = 'S' then 'Segunda-Feira ' else '' end +
 case when cp.ic_ter_entrega = 'S' then 'Terça-Feira '   else '' end + 
 case when cp.ic_qua_entrega = 'S' THEN 'Quarta-Feira '  else '' end +
 case when cp.ic_qui_entrega = 'S' then 'Quinta-Feira '  else '' end +
 case when cp.ic_sex_entrega = 'S' then 'Sexta-Feira '   else '' end +
 case when cp.ic_sab_entrega = 'S' then 'Sabado '        else '' end +
 case when cp.ic_dom_entrega = 'S' then 'Domingo '       else '' end 
	  + isnull(cp.hr_entrega_cliente,'') as entrega 

	
 into   
 #Cliente  
  
from cliente c with(nolock)  
 left outer join Cidade ci            with(nolock) on ci.cd_cidade  = c.cd_cidade and ci.cd_estado = c.cd_estado  
 left outer join Estado e             with(nolock) on e.cd_estado   = c.cd_estado  
 left outer join Segmento_Mercado sm  with(nolock) on sm.cd_usuario = c.cd_usuario  
 left outer join Regiao r             with(nolock) on r.cd_regiao   = c.cd_regiao  
 left outer join Cliente_Perfil cp    with(nolock) on cp.cd_cliente = c.cd_cliente  
   
 where c.cd_cliente = @cd_cliente --939

--------------------------------------------------------------------------------------------------------------  
declare @nm_fantasia_cliente         nvarchar(60)  
declare @nm_razao_social             nvarchar(60)  
declare @nm_email_cliente            nvarchar(60)  
declare @dt_cadastro_cliente         nvarchar(15)  
declare @cd_cnpj_cliente_cliente     nvarchar(20)  
declare @cd_inscricao_estadual       nvarchar(40)   
declare @cd_cep                      nvarchar(40)  
declare @nm_complemento_endereco     nvarchar(60)   
declare @nm_endereco_cliente         nvarchar(60)  
declare @nm_bairro                   nvarchar(60)  
declare @nm_cidade_relatorio         nvarchar(60)  
declare @nm_estado                   nvarchar(60)  
declare @cd_telefone                 nvarchar(60)  
declare @nm_segmento_mercado         nvarchar(40)  
declare @nm_regiao                   nvarchar(40)  
declare @ds_perfil_cliente           nvarchar(100)
declare @ds_perfil_entrega_cliente   nvarchar(40)
declare @nm_restricao_entrega        nvarchar(50)
declare @dia_entrega                 nvarchar(100)
-------------------------------------------------------------------------------------------------------------  
select   
   
 @nm_fantasia_cliente       = nm_fantasia_cliente,  
 @nm_razao_social           = nm_razao_social_cliente,  
 @nm_email_cliente          = nm_email_cliente,  
 @dt_cadastro_cliente       = Convert(varchar(15),dt_cadastro_cliente, 103),  
 @cd_cnpj_cliente_cliente   = cd_cnpj_cliente,  
 @cd_inscricao_estadual     = cd_inscestadual,  
 @cd_cep                    = cd_cep,  
 @nm_complemento_endereco   = nm_complemento_endereco,  
 @nm_endereco_cliente       = nm_endereco_cliente,   
 @nm_bairro                 = nm_bairro,  
 @nm_cidade_relatorio       = nm_cidade,  
 @nm_estado                 = nm_estado,  
 @cd_telefone               = cd_telefone,  
 @nm_segmento_mercado       = nm_segmento_mercado,  
 @nm_regiao                 = nm_regiao,
 @ds_perfil_cliente         = ds_perfil_cliente,
 @ds_perfil_entrega_cliente = ds_perfil_entrega_cliente,
 @nm_restricao_entrega      = nm_restricao_entrega,
 @dia_entrega               = entrega
  
  
from #Cliente  

--------------------------------------------------------------------------------------------------------------  
set @html_geral = '<div>  
  <p class="section-title" style="text-align: center; padding: 8px;">CLIENTE</p>  
 </div>  
 <div>  
    <table>  
      <tr>  
        <th>Nome Fantasia</th>  
        <td>'+isnull(@nm_fantasia_cliente,'')+'</td>  
      </tr>  
      <tr>  
        <th>Razão Social</th>  
        <td>'+isnull(@nm_razao_social,'')+'</td>  
      </tr>  
      <tr>  
        <th>Data de Cadastro</th>  
        <td>'+isnull(@dt_cadastro_cliente,'')+'</td>  
      </tr>  
      <tr>  
        <th>CNPJ/CPF</th>  
        <td>'+isnull(@cd_cnpj_cliente_cliente,'')+'</td>  
      </tr>  
      <tr>  
        <th>Endereço</th>  
        <td>'+isnull(@nm_endereco_cliente,'')+'</td>  
      </tr>  
      <tr>  
        <th>Complemento</th>  
        <td>'+cast(isnull(@nm_complemento_endereco,'') as nvarchar(50))+'</td>  
      </tr>  
      <tr>  
        <th>Bairro</th>  
        <td>'+isnull(@nm_bairro,'')+'</td>  
      </tr>  
      <tr>  
        <th>CEP</th>  
        <td>'+cast(isnull(@cd_cep,'') as nvarchar(20))+'</td>  
      </tr>  
      <tr>  
        <th>Inscrição Estadual</th>  
        <td>'+cast(isnull(@cd_inscricao_estadual,'')as nvarchar(20))+'</td>  
      </tr>  
      <tr>  
        <th>Cidade</th>  
        <td>'+isnull(@nm_cidade_relatorio,'')+'</td>  
      </tr>  
      <tr>  
        <th>Estado</th>  
        <td>'+isnull(@nm_estado,'')+'</td>  
      </tr>  
      <tr>  
        <th>Região</th>  
        <td>'+isnull(@nm_regiao,'')+'</td>  
      </tr>  
      <tr>  
        <th>Segmento de Mercado</th>  
        <td>'+isnull(@nm_segmento_mercado,'')+'</td>  
      </tr>  
      <tr>  
        <th>Perfil</th>  
        <td>'+isnull(@ds_perfil_cliente,'')+'</td>  
      </tr>  
      <tr>  
        <th>Email</th>  
        <td>'+isnull(@nm_email_cliente,'')+'</td>  
      </tr>  
      <tr>  
        <th>Telefone</th>  
        <td>'+isnull(@cd_telefone,'')+'</td>  
      </tr>'  
		+ CASE WHEN ISNULL(@ds_perfil_entrega_cliente, '') = '' THEN
		'' 
		 ELSE 
	 '<tr>  
        <th>Perfil Entrega</th>  
        <td>' + @ds_perfil_entrega_cliente + '</td>  
    </tr>'
		END
	 + '
	 '+
	 case when isnull(@nm_restricao_entrega,'') = '' then 
	 '<tr>  
        <th>Restrição Entrega</th>  
        <td>Sem Restrições</td>  
      </tr>'
	 else 
	 '<tr>  
        <th>Restrição Entrega</th>  
        <td>' + @nm_restricao_entrega + '</td>  
    </tr>'
		END
	 + '
	 <tr>  
        <th>Entrega</th>  
        <td>'+isnull(@dia_entrega,'')+'</td>  
      </tr>  
	 </table>  
	 </div>'  
          
--------------------------------------------------------------------------------------------------------------  
  
--------------------------------------------------------------------------------------------------------------------  
set @html_rodape =  
    '</table>  
     <div class="company-info">  
       <p><strong>'+@footerTitle+'</strong></p>  
     </div>  
     <p>'+@ds_relatorio+'</p>  
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
select isnull(@html,'') as RelatorioHTML, 'Cliente_' +cast(@cd_cliente as varchar) as pdfName
-------------------------------------------------------------------------------------------------------------------------------------------------------  
  
go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_relatorio_cliente '[{"cd_cliente": 3584, "cd_menu": 5387, "cd_parametro": 24, "cd_relatorio": 244, "cd_usuario": 4254}]' 
------------------------------------------------------------------------------

