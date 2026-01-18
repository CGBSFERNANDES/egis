IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_entregas_nao_efetuadas_faturamento' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_entregas_nao_efetuadas_faturamento

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_entregas_nao_efetuadas_faturamento
-------------------------------------------------------------------------------
--pr_egis_relatorio_entregas_nao_efetuadas_faturamento
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
create procedure pr_egis_relatorio_entregas_nao_efetuadas_faturamento
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
--declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @ic_valor_comercial     varchar(10)
declare @cd_tipo_destinatario   int 
declare @cd_grupo_relatorio     int 
declare @cd_servico             int = 0 
declare @id                     int = 0 
declare @cd_pedido_entrega      int = 0
declare @cd_veiculo             int = 0 
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
------------------------------------------------------------------------------------------------

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
  select @cd_cliente             = valor from #json where campo = 'cd_cliente'
  select @cd_servico             = valor from #json where campo = 'cd_servico'
  select @cd_veiculo             = valor from #json where campo = 'cd_veiculo'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_parametro           = valor from #json where campo = 'cd_parametro'


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
select  
  @dt_inicial       = dt_inicial,  
  @dt_final         = dt_final,
  @cd_cliente       = isnull(cd_cliente,0), 
  @cd_servico       = isnull(cd_servico,0), 
  @cd_veiculo       = isnull(cd_veiculo,0) 
from   
  Parametro_Relatorio  
  
where  
  cd_relatorio = @cd_relatorio  
  and  
  cd_usuario   = @cd_usuario  
---------------------------------------------------------------------------------------------------------------------------
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
--Cabe�alho da Empresa----------------------------------------------------------------------------------------------------------------------
-----------------------

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
      padding: 20px;
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
    .linha-simples {
	  border-bottom: 1px solid #ddd;
      padding: 10px;
    }
     @media print {
     .quebraPagina {
        page-break-after: always;
            }
        }
  </style>
</head>
<body>
   
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:30%; margin-right:20px">
			<img src="'+isnull(@logo,'')+'" alt="Logo da Empresa">
		</div>
		<div style="width:70%; padding-left:10px">
			<p class="title">'+isnull(@nm_fantasia_empresa,'')+'</p>
		    <p><strong>'+isnull(@nm_endereco_empresa,'')+', '+isnull(@cd_numero_endereco_empresa,'')+ ' - '+isnull(@cd_cep_empresa,'')+ ' - '+isnull(@nm_cidade,'')+' - '+isnull(@sg_estado,'')+' - ' +isnull(@nm_pais,'')+'</strong></p>
		    <p><strong>Fone: </strong>'+isnull(@cd_telefone_empresa,'')+' - <strong>CNPJ: </strong>' + isnull(@cd_cnpj_empresa,'') + ' - <strong>I.E: </strong>' + isnull(@cd_inscestadual_empresa,'') + '</p>
		    <p>'+isnull(@nm_dominio_internet,'')+ ' - ' +isnull(@nm_email_internet,'')+'</p>
		</div>    
    </div>'

--select @html_empresa

		

--Detalhe--
  
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
  

  
drop table #AuxRelAtributo  
  
  
if isnull(@cd_parametro,0) = 2  
 begin  
  select * from #RelAtributo  
  return  
end  

set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)




--------------------------------------------------------------------------------------------------------------------------
 select

 0                                                as sel,    
  0                                                as gerado,    
  vw.*,    
   case when isnull(vw.ic_diaria,'N') = 'S'
   then (select
           sum(case when (DATEPART(dw,a.dt_agenda) = 1) or (af.dt_agenda_feriado is not null)
                 then case when vwa.vl_hora_extra_domingo = 0
                        then vwa.vl_servico_entrega*24
                         else vwa.vl_hora_extra_domingo*24
                      end
                 else case when DATEPART(dw,a.dt_agenda) in (2,3,4,5,6)
                        then vwa.vl_servico_entrega*24
                        else case when DATEPART(dw,a.dt_agenda) = 7
                               then case when vwa.vl_hora_extra_sabado = 0
                                      then vwa.vl_servico_entrega*24
                                      else vwa.vl_hora_extra_sabado*24
                                    end
                               else vwa.vl_servico_entrega*24
                             end
                      end
               end)
         from
           Agenda a                              with(nolock)
           left outer join Agenda_Feriado af     with(nolock) on af.dt_agenda_feriado  = a.dt_agenda
           left outer join vw_pedido_entrega vwa with(nolock) on vwa.cd_pedido_entrega = vw.cd_pedido_entrega
         where
           a.dt_agenda between vw.dt_chegada and vw.dt_saida)
   else
   case when (isnull(hr_chegada,'') <> '' and isnull(hr_saida,'') <> '')  
   then case when (vw.cd_semana = 1) or (exists (select top 1 dt_agenda_feriado from Agenda_Feriado where dt_agenda_feriado = vw.dt_entrega))
          then case when vw.vl_hora_extra_domingo = 0
                 then vw.vl_servico_entrega
                 else vw.vl_hora_extra_domingo
               end
          else 
   case when vw.cd_semana in (2,3,4,5,6)  
     then case when ((convert(datetime,left(convert(varchar,vw.dt_chegada,121),10)+' '+hr_chegada+':00',121) <  
                     convert(datetime,left(convert(varchar,vw.dt_chegada,121),10)+' '+'08:00:00',121)) or  
                    (convert(datetime,left(convert(varchar,vw.dt_chegada,121),10)+' '+hr_chegada+':00',121) >  
                     convert(datetime,left(convert(varchar,vw.dt_chegada,121),10)+' '+'17:00:00',121)))  
            then case when vw.vl_hora_extra = 0
                   then vw.vl_servico_entrega
                   else vw.vl_hora_extra
                 end
            else case when ((convert(datetime,left(convert(varchar,vw.dt_saida,121),10)+' '+hr_saida+':00',121) >  
                            convert(datetime,left(convert(varchar,vw.dt_saida,121),10)+' '+'17:00:00',121)) or  
                           (convert(datetime,left(convert(varchar,vw.dt_saida,121),10)+' '+hr_saida+':00',121) <  
                            convert(datetime,left(convert(varchar,vw.dt_saida,121),10)+' '+'08:00:00',121)))  
                   then case when vw.vl_hora_extra = 0
                          then vw.vl_servico_entrega
                          else vw.vl_hora_extra
                        end
                   else vw.vl_servico_entrega  
                 end  
          end  
     else case when vw.cd_semana = 7  
            then case when ((convert(datetime,left(convert(varchar,vw.dt_chegada,121),10)+' '+hr_chegada+':00',121) <  
                            convert(datetime,left(convert(varchar,vw.dt_chegada,121),10)+' '+'08:00:00',121)) or  
                           (convert(datetime,left(convert(varchar,vw.dt_chegada,121),10)+' '+hr_chegada+':00',121) >  
                            convert(datetime,left(convert(varchar,vw.dt_chegada,121),10)+' '+'11:00:00',121)))  
                   then case when vw.vl_hora_extra_sabado = 0
                          then vw.vl_servico_entrega
                          else vw.vl_hora_extra_sabado
                        end
                   else case when ((convert(datetime,left(convert(varchar,vw.dt_saida,121),10)+' '+hr_saida+':00',121) >  
                                   convert(datetime,left(convert(varchar,vw.dt_saida,121),10)+' '+'11:00:00',121)) or  
                                  (convert(datetime,left(convert(varchar,vw.dt_saida,121),10)+' '+hr_saida+':00',121) <  
                                   convert(datetime,left(convert(varchar,vw.dt_saida,121),10)+' '+'08:00:00',121)))  
                          then case when vw.vl_hora_extra_sabado = 0
                                 then vw.vl_servico_entrega
                                 else vw.vl_hora_extra_sabado
                               end
                          else vw.vl_servico_entrega  
                        end  
                 end  
            else vw.vl_servico_entrega  
          end  
   end end else vw.vl_servico_entrega end end                      as vl_servico, 
   -----------------------------------------------------    
  --Quantidade do Romaneio-------------    
  qt_envida = 0,    
  ---    
  case when isnull(vw.cd_ddd,'')<>'' then    
    ltrim(rtrim(vw.cd_ddd))    
  else    
    cast('' as varchar(1))    
  end    
  +    
  case when isnull(vw.cd_telefone,'')<>'' then    
    ltrim(rtrim(vw.cd_telefone))    
  else    
    cast('' as varchar(1))    
  end                                        as cd_fone_cliente,    
    
  --Endereço-----------------------------------------------------------    
  ltrim(rtrim(isnull(vw.nm_endereco,'')))    
  +    
  ', '     
  +    
  ltrim(rtrim(isnull(vw.cd_numero,'')))    
  +    
  ' - '    
  +    
  ltrim(rtrim(isnull(vw.nm_bairro,'')))    
  +     
  ' - '     
  +    
  ltrim(rtrim(isnull(vw.nm_cidade,'')))    
  +    
  '/'    
  +    
  ltrim(rtrim(isnull(vw.sg_estado,'')))    
  as                                                 nm_endereco_apresenta,    
    
  case when (vw.dt_entrega < @dt_hoje) and (isnull(vw.cd_romaneio,0) = 0)    
    then 'S'    
    else 'N'    
  end                                                as AtrasoSemEnvio,    
    
  case when (vw.dt_entrega < @dt_hoje) and (isnull(vw.cd_romaneio,0) <> 0)    
    then 'S'    
    else 'N'    
  end                                                as AtrasoComEnvio,    
    
  case when (vw.dt_entrega >= @dt_hoje) and (isnull(vw.cd_romaneio,0) = 0)    
    then 'S'    
    else 'N'    
  end                                                as EmDiaSemEnvio,    
    
  case when (vw.dt_entrega >= @dt_hoje) and (isnull(vw.cd_romaneio,0) <> 0)    
    then 'S'    
    else 'N'    
  end                                                as EmDiaComEnvio,    
    
  case when vw.dt_entrega_efetiva is not null    
    then 'S'    
    else 'N'    
  end                                                as Entregue,    
    
  case when isnull(vw.cd_nota_saida,0) <> 0    
    then 'S'    
    else 'N'    
  end                                                as Faturado,
  
  c.nm_cidade                                        as nm_cidade_cli,
  e.sg_estado                                        as sg_estado_cli

into    
  #EntregaFaturamento    
    
from    
  vw_pedido_entrega vw   
left outer join Pais p    on p.cd_pais = vw.cd_pais
left outer join Estado e  on e.cd_pais = vw.cd_pais and e.cd_estado = vw.cd_estado 
left outer join cidade c  on c.cd_pais = vw.cd_pais and c.cd_estado = vw.cd_estado and c.cd_cidade = vw.cd_cidade
    
where    
--vw.cd_romaneio = 55025
  isnull(vw.cd_pedido_venda,0) <> 0
  and
  vw.dt_entrega_efetiva is not null   
  and
  isnull(vw.hr_saida,'') <> ''
  and
  isnull(vw.hr_chegada,'') <> ''
  and 
  vw.dt_entrega between @dt_inicial and @dt_final   
  and    
  vw.cd_cliente = case when isnull(@cd_cliente,0) = 0 then vw.cd_cliente else isnull(@cd_cliente,0) end    
  and    
  vw.cd_servico = case when isnull(@cd_servico,0) = 0 then vw.cd_servico else isnull(@cd_servico,0) end    
  and    
  vw.cd_pedido_entrega = case when isnull(@cd_pedido_entrega,0) = 0 then vw.cd_pedido_entrega else isnull(@cd_pedido_entrega,0) end    
  and    
  isnull(vw.cd_veiculo,0) = case when isnull(@cd_veiculo,0) = 0 then isnull(vw.cd_veiculo,0) else isnull(@cd_veiculo,0) end 
order by
vw.cd_cliente,
vw.dt_entrega
  --select * from #EntregaFaturamento
  --return
-----------------------------------------------------------------------------------------------------------------------------------------
  select     
    *,    
    (cast(DATEDIFF(minute,convert(datetime,left(convert(varchar,dt_chegada,121),10)+' '+hr_chegada+':00',121)    
                      ,convert(datetime,left(convert(varchar,dt_saida,121),10)+' '+hr_saida+':00',121))as decimal(25,2)))  as Minutos,    
    
    case when (cast(DATEDIFF(minute,convert(datetime,left(convert(varchar,dt_chegada,121),10)+' '+hr_chegada+':00',121)    
                                ,convert(datetime,left(convert(varchar,dt_saida,121),10)+' '+hr_saida+':00',121))as decimal(25,2))) -    
               isnull(qt_minuto_tol,0) - isnull(qt_tolerancia,0) < 0     
   then 0       
   else case when ic_hora_cheia = 'S' then (CEILING(
        ((cast(DATEDIFF(minute,convert(datetime,left(convert(varchar,dt_chegada,121),10)+' '+hr_chegada+':00',121)      
                             ,convert(datetime,left(convert(varchar,dt_saida,121),10)+' '+hr_saida+':00',121))as decimal(25,2))) -      
            isnull(qt_minuto_tol,0) - isnull(qt_tolerancia,0))/60) * 60) 
        else 
        ((cast(DATEDIFF(minute,convert(datetime,left(convert(varchar,dt_chegada,121),10)+' '+hr_chegada+':00',121)      
                             ,convert(datetime,left(convert(varchar,dt_saida,121),10)+' '+hr_saida+':00',121))as decimal(25,2))) -      
            isnull(qt_minuto_tol,0) - isnull(qt_tolerancia,0))
        end
 end                                                                                                                      as Minuto_Exced   
  into
    #EntregaFaturamentoRel    
 
 from #EntregaFaturamento    
  where     
    dt_cancelamento is null    
    and    
    case when isnull(ic_fracionado,'') = '' then 'N' else 'S' end = 'N'    
    
  select    
   identity(int,1,1) as cd_controle,
   a.*,    
  (a.vl_hora_excedente_total)/case when isnull(a.qt_minuto_tol,0) = 0 then 1 else a.qt_minuto_tol end as vl_hora_excedente,    
  (a.Minuto_Exced * a.vl_hora_excedente_total)/case when isnull(a.qt_minuto_tol,0) = 0 then 1 else a.qt_minuto_tol end as TotExced,    
   a.qt_entrega * a.vl_servico as TotM3,    
  (a.qt_entrega * a.vl_servico)+((a.Minuto_Exced * a.vl_hora_excedente_total)/case when isnull(a.qt_minuto_tol,0) = 0 then 1 else a.qt_minuto_tol end) as TotEntrega,    
   case when isnull(ef.nm_fantasia_empresa,'') <> '' then
     isnull(ef.nm_fantasia_empresa,'')
   else
     case when isnull(b.nm_fantasia_empresa,'') = '' then c.nm_fantasia_empresa else b.nm_fantasia_empresa end
   end as nm_fantasia_empresa,    
   b.nm_logotipo_empresa as nm_logotipo_emp_faturamento,    
   case when isnull(a.ic_tipo_faturamento,'S') = 'S' then 'Serviço' else 'Produto' end as nm_tipo_faturamento
   
   into 
   #EntregaFaturamentoFinal
  from    
    #EntregaFaturamentoRel a with(nolock)    
    left outer join empresa_faturamento b           with(nolock) on b.cd_empresa = a.cd_empresa_faturamento    
    left outer join EGISADMIN.dbo.Empresa c         with(nolock) on c.cd_empresa = @cd_empresa    
    left outer join Cliente_Empresa cliemp          with(nolock) on cliemp.cd_cliente = case when a.cd_cliente_faturar > 0 then a.cd_cliente_faturar else a.cd_cliente end
    left outer join empresa_faturamento ef          with(nolock) on ef.cd_empresa = cliemp.cd_empresa  

  order by    
    a.cd_cliente,    
    a.dt_entrega    
	

declare @vl_total_TotM3 float
declare @vl_qt_entrega float
declare @vl_total_hora_excedente float
declare @vl_total_entrega_geral float
declare @qt_romaneio int
SELECT 
    r.cd_cliente,
    SUM(r.TotM3)             AS vl_total_TotM3,
    SUM(r.qt_entrega)        AS vl_qt_entrega,
    SUM(r.vl_hora_excedente) AS vl_total_hora_excedente,
    SUM(r.vl_total_entrega)  AS vl_total_entrega_geral,
    count(r.cd_romaneio)     AS qt_romaneio
	into 
	#TotalFaturamento
FROM #EntregaFaturamentoFinal r
GROUP BY r.cd_cliente
--select * from #TotalFaturamento --where cd_cliente = 2467 
--return
--------------------------------------------------------------------------------------------------------------------------

if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #EntregaFaturamentoFinal  
  return  
 end
--------------------------------------------------------------------------------------------------------------------------

declare @cd_cliente_rel      int = 0
declare @nm_endereco_cliente varchar(200) = '' 
declare @cd_numero_cliente   varchar(12) = ''
declare @nm_bairro_cliente   varchar(200) = '' 
declare @nm_complemento_end  varchar(200) = '' 
declare @cd_cep              varchar(12) = ''
declare @cd_ddd				 varchar(12) = ''
declare @cd_ddd_celular      varchar(10) = ''
declare @cd_telefone         varchar(25) = ''
declare @cd_celular          varchar(15) = ''

---select @dt_inicial

set @html_geral = '  
     <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 21%;">'+isnull(@titulo,'')+'</p>  
    </div>  
	
'
--------------------------------------------------------------------------------------------------------------------------
while exists ( select top 1 cd_cliente from #EntregaFaturamento)
begin
	select top 1

	    @cd_cliente_rel           = cd_cliente,
		@nm_razao_social_cliente  = nm_razao_social_cliente,
		@nm_endereco_cliente      = nm_endereco,
		@cd_numero_cliente        = cd_numero,
		@nm_bairro_cliente        = nm_bairro,
		@nm_cidade_cliente        = nm_cidade_cli,
		@sg_estado_cliente        = sg_estado_cli,
		@nm_complemento_end       = nm_complemento,
		@cd_cep     			  = cd_cep_entrega,
		@cd_telefone			  = cd_telefone,
		@cd_celular               = cd_celular_cliente,
		@cd_ddd_celular           = cd_ddd_celular_cliente,
		@cd_ddd                   = cd_ddd

	from #EntregaFaturamento

	  SELECT 
        @vl_total_TotM3          = vl_total_TotM3,
        @vl_qt_entrega           = vl_qt_entrega,
        @vl_total_hora_excedente = vl_total_hora_excedente,
        @vl_total_entrega_geral  = vl_total_entrega_geral,
        @qt_romaneio             = qt_romaneio
    FROM #TotalFaturamento
    WHERE cd_cliente = @cd_cliente_rel
set  @html_geral = @html_geral + '
    <p class="linha-simples"></p>
  <table style="width: 100%;border: none;">
    <tr>
     <td style="border: none;font-weight:bold;">Razão Social</td>
    </tr>
    <tr>
     <td style="border: none;">'+ISNULL(@nm_razao_social_cliente,'')+' ('+cast(isnull(@cd_cliente_rel,0)as nvarchar(20))+')</td>
    </tr>
	</table>
	<table style="width: 100%;border: none;">
    <tr>
      <td style="border: none;font-weight:bold;">Endereço</td>
      <td style="border: none;font-weight:bold;">Nº</td>
      <td style="border: none;font-weight:bold;">Complemento</td>
      <td style="border: none;font-weight:bold;">Bairro</td>
      <td style="border: none;font-weight:bold;">Cidade</td>
      <td style="border: none;font-weight:bold;">UF</td>
    </tr>
    <tr>
      <td style="border: none;">'+isnull(@nm_endereco_cliente,'')+'</td>
      <td style="border: none;">'+ISNULL(@cd_numero_cliente,'')+'</td>
      <td style="border: none;">'+ISNULL(@nm_complemento_end,'')+'</td>
      <td style="border: none;">'+ISNULL(@nm_bairro_cliente,'')+'</td>
      <td style="border: none;">'+ISNULL(@nm_cidade_cliente,'')+'</td>
      <td style="border: none;">'+ISNULL(@sg_estado_cliente,'')+'</td>
    </tr>
	</table>
	<table style="width: 100%;border: none;">
    <tr>
      <td style="border: none;font-weight:bold;">CEP</td>
      <td style="border: none;font-weight:bold;">TELEFONE</td>
      <td style="border: none;font-weight:bold;">CELULAR</td>
    </tr>
    <tr>
      <td style="border: none;">'+ISNULL(@cd_cep,'')+'</td>
      <td style="border: none;">('+cast(ISNULL(@cd_ddd,0) as varchar(10))+') '+cast(ISNULL(@cd_telefone,0) as varchar(10))+'</td>
      <td style="border: none;">('+cast(ISNULL(@cd_ddd_celular,0) as varchar(10))+') '+cast(ISNULL(@cd_celular,0) as varchar(10))+'</td>
    </tr>  
  </table>
  <p class="linha-simples"></p>
    <table style="width: 100%;border: none;">
        <tr> 
            <td style="text-align: right;border: none;font-weight:bold;"></td>
            <td style="text-align: right;border: none;font-weight:bold;"></td>
            <td style="text-align: right;border: none;font-weight:bold;"></td>
            <td style="text-align: right;border: none;font-weight:bold;"></td>
            <td style="text-align: right;border: none;font-weight:bold;">Aquisição de Água</td>
            <td style="text-align: right;border: none;font-weight:bold;">Tempo Excendente</td>
            <td style="text-align: right;border: none;font-weight:bold;"></td>
    </tr>
  <table style="margin-top: 20px;">
    <tr>
      <th>Data</th>
      <th>Romaneio</th>
      <th>Serviço</th>
      <th>Permanência</th>
      <th>Minutos</th>
      <th>m3</th>
      <th>Preço m3</th>
      <th>Total m3</th>
      <th>Minutos</th>
      <th>Valor</th>
      <th>Total</th>
      <th>Total Entrega</th>
    </tr>' 
--------------------------------------------------------------------------------------------------------------

while exists ( select top 1 cd_controle from #EntregaFaturamentoFinal where cd_cliente = @cd_cliente_rel)
begin
	select top 1

		@id                      = cd_controle,
		
		@html_geral = @html_geral +'
		      <tr class="tamanho">
		          <td>'+ISNULL(dbo.fn_data_string(dt_entrega),'')+'</td>
                  <td>'+cast(isnull(cd_romaneio,0) as varchar(15))+'</td>
                  <td>'+isnull(nm_servico,'')+'</td>
                  <td>'+isnull(hr_chegada,'')+' / '+isnull(hr_saida,'')+'</td>
                  <td>'+cast(isnull(Minutos,0)as nvarchar(20))+'</td>
                  <td>'+cast(isnull(dbo.fn_formata_valor(qt_entrega),0) as varchar(15))+'</td>
                  <td>'+cast(isnull(dbo.fn_formata_valor(vl_servico),0) as varchar(15))+'</td>
                  <td>'+cast(isnull(dbo.fn_formata_valor(TotM3),0) as varchar(15))+'</td>
                  <td>'+cast(isnull(Minuto_Exced,'')as nvarchar(20))+'</td> 
                  <td>'+cast(isnull(dbo.fn_formata_valor(TotExced),0) as varchar(15))+'</td>
                  <td>'+cast(isnull(dbo.fn_formata_valor(vl_hora_excedente),0) as varchar(15))+'</td>
                  <td>'+cast(isnull(dbo.fn_formata_valor(vl_total_entrega),0) as varchar(15))+'</td>
			   </tr>'
     
	from #EntregaFaturamentoFinal
	where cd_cliente = @cd_cliente_rel
	order by  
	   cd_cliente

  delete from #EntregaFaturamentoFinal 
    where cd_controle = @id
 end
             
	set @html_geral = @html_geral + '
			      <tr class="quebraPagina">
		          <td style="font-weight: bold;text-align: center;">Total</td>
                  <td style="font-weight: bold;text-align: center;">'+cast(isnull(@qt_romaneio,0) as varchar(15))+'</td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td style="font-weight: bold;text-align: center;">'+cast(isnull(dbo.fn_formata_valor(@vl_qt_entrega),0) as varchar(15))+'</td>
                  <td></td>
                  <td style="font-weight: bold;text-align: center;">'+cast(isnull(dbo.fn_formata_valor(@vl_total_TotM3),0) as varchar(15))+'</td>
                  <td></td> 
                  <td></td>
                  <td style="font-weight: bold;text-align: center;">'+cast(isnull(dbo.fn_formata_valor(@vl_total_hora_excedente),0) as varchar(15))+'</td>
                  <td style="font-weight: bold;text-align: center;">'+cast(isnull(dbo.fn_formata_valor(@vl_total_entrega_geral),0) as varchar(15))+'</td>
			   </tr>
			   </table>'

  delete from #EntregaFaturamento
	where cd_cliente = @cd_cliente_rel
 end
     

--------------------------------------------------------------------------------------------------------------------
set @html_rodape =
    '</table>
    <p>'+isnull(@ds_relatorio,'')+'</p>
	<div class="report-date-time">
       <p style="text-align:right">Gerado em: '+isnull(@data_hora_atual,'')+'</p>
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

--use egissql_345
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_egis_relatorio_entregas_nao_efetuadas_faturamento 371,'[{
--    "cd_menu": "0",
--    "cd_form": 188,
--    "cd_documento_form": 3,
--    "cd_parametro_form": "2",
--    "cd_usuario": "4801",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "4801",
--    "dt_usuario": "2025-08-22",
--    "lookup_formEspecial": {},
--    "cd_parametro_relatorio": "3",
--    "cd_relatorio": "371",
--    "dt_inicial": "2025-08-01",
--    "dt_final": "2025-08-30",
--    "cd_cliente": 0,
--    "cd_veiculo": 0,
--    "cd_servico": null,
--    "detalhe": [],
--    "lote": [],
--    "cd_modulo": "319"
--}]'
------------------------------------------------------------------------------

