IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_documento_pagos' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_documento_pagos

GO
--use egissql_360
-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_documento_pagos
-------------------------------------------------------------------------------
--pr_egis_relatorio_documento_pagos
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
--use egissql_370
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_documento_pagos
@cd_relatorio int   = 0,
@cd_parametro int   = 0,
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
			font-size:12px;
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
    declare @cd_portador               int = 0
	declare @ic_rateio                 int = 0
	declare @cd_plano_financeiro       int = 0
	declare @cd_centro_custo           int         = 0	
	--set @dt_inicial = '10-01-2025'
	--set @dt_final  = '12-30-2025' 
------------------------------------------------------------------------------------------------------------
	select  
      (ROW_NUMBER() OVER(ORDER BY d.cd_documento_pagar)) as cd_controle,
      p.dt_pagamento_documento,  

      case when (isnull(d.cd_empresa_diversa, 0) <> 0) then isnull(cast((select top 1 z.sg_empresa_diversa from empresa_diversa z where z.cd_empresa_diversa = d.cd_empresa_diversa) as varchar(30)),d.nm_fantasia_fornecedor)    
           when (isnull(d.cd_contrato_pagar, 0)  <> 0) then isnull(cast((select top 1 w.nm_fantasia_fornecedor from contrato_pagar w where w.cd_contrato_pagar = d.cd_contrato_pagar) as varchar(30)),d.nm_fantasia_fornecedor)    
           when (isnull(d.cd_funcionario, 0)     <> 0) then isnull(cast((select top 1 k.nm_funcionario from funcionario k where k.cd_funcionario = d.cd_funcionario) as varchar(30)),d.nm_fantasia_fornecedor)    
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then cast(d.nm_fantasia_fornecedor as varchar(30))  
      end                             as 'cd_favorecido',                 

      case when (isnull(d.cd_empresa_diversa, 0) <> 0) then cast((select top 1 z.nm_empresa_diversa from empresa_diversa z where z.cd_empresa_diversa = d.cd_empresa_diversa) as varchar(50))  
           when (isnull(d.cd_contrato_pagar, 0) <> 0)  then cast((select top 1 w.nm_contrato_pagar from contrato_pagar w where w.cd_contrato_pagar = d.cd_contrato_pagar) as varchar(50))  
           when (isnull(d.cd_funcionario, 0) <> 0)     then cast((select top 1 k.nm_funcionario from funcionario k where k.cd_funcionario = d.cd_funcionario) as varchar(50))  
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then cast((select top 1 o.nm_razao_social from fornecedor o where o.nm_fantasia_fornecedor = d.nm_fantasia_fornecedor) as varchar(50))    
      end                             as nm_favorecido,     
      cast(case when isnull(d.cd_favorecido_empresa,0)=0
      then 
         ''
      else
        ( select top 1 fe.nm_favorecido_empresa 
          from 
             favorecido_empresa fe with (nolock) 
          where
             fe.cd_empresa_diversa        = d.cd_empresa_diversa and 
             fe.cd_favorecido_empresa_div = d.cd_favorecido_empresa )
      end as varchar(30))             as 'nm_favorecido_empresa',

      max(case when vw.cd_tipo_pessoa = 1 or z.cd_tipo_pessoa = 1 then  
        dbo.fn_Formata_Mascara('99.999.999/9999-99', isnull(vw.cd_cnpj,z.cd_cnpj_empresa_diversa))    
      else  
        dbo.fn_Formata_Mascara('999.999.999-99',  
                         vw.cd_cnpj)   
      end)                   as cd_cnpj, 

      max(case when (isnull(d.cd_empresa_diversa, 0) <> 0)
      then   
         z.nm_empresa_diversa
      else    
         case when (isnull(d.cd_contrato_pagar, 0) <> 0) 
         then   
             vw.nm_fantasia
         else  
            case when (isnull(d.cd_funcionario, 0) <> 0) 
            then   
               k.nm_funcionario   
            else
              case when (isnull(d.nm_fantasia_fornecedor, '') <> '') or isnull(d.cd_tipo_destinatario,2)<>0 
              then   
                 case when isnull(d.cd_tipo_destinatario,2)=1 then
                   vw.nm_razao_social
                 else
                   vw.nm_razao_social
                 end
              else
                 ''
              end
            end
         end
      end)                                   as 'nm_razao_social',  

      t.sg_tipo_conta_pagar,  
      d.cd_identificacao_document,
      d.cd_documento_pagar,
      pg.sg_tipo_pagamento,  

--      p.cd_identifica_documento,  

      cast(case when isnull(p.cd_identifica_documento,'') <> '' then 
	         isnull(p.cd_identifica_documento,'')
		   else
		     isnull(d.cd_identificacao_document,'') 
		   end
	   as varchar(30))  as cd_identifica_documento,

      p.vl_pagamento_documento,  
      p.vl_juros_documento_pagar,  
      p.vl_desconto_documento,  
      p.vl_abatimento_documento,  

      max(isnull(d.cd_ap,0))              as cd_ap,

      tcp.ic_tipo_bordero,  

      case when isnull(pg.ic_zera_tipo_pagamento,'N') = 'N'
      then
        (p.vl_pagamento_documento + isnull(d.vl_outros_documento,0)+ 
         isnull(p.vl_juros_documento_pagar,0) -  
         isnull(p.vl_desconto_documento,0) -  
         isnull(p.vl_abatimento_documento,0)) +
		 isnull(p.vl_outros_pagamento,0)

      else
         0.00
      end                  as 'vl_total',  

      d.dt_emissao_documento_paga,  
  
      case when e.dt_receb_nota_entrada is null then  
        d.dt_emissao_documento_paga  
      else   
        e.dt_receb_nota_entrada end as 'dt_recebimento',  
     
      pf.cd_mascara_plano_financeiro,

  --	  case when isnull(dpf.vl_plano_financeiro,0) <> 0 then
		--'**Rateio**' 
	 -- else
	 --   pf.nm_conta_plano_financeiro
  --    end                                        as nm_conta_plano_financeiro,

      case when isnull(d.cd_plano_financeiro,0)<>0 then
         pf.nm_conta_plano_financeiro
      else
         --Verifica se existe Rateio
         case when exists ( select top 1 dpf.cd_documento_pagar from Documento_pagar_plano_financ dpf
                            where dpf.cd_documento_pagar = d.cd_documento_pagar )
         then '** Rateio de Plano Financeiro **' else '' end
            
      end                                             as 'nm_conta_plano_financeiro',

      l.nm_fantasia_loja,
      cast(case when @cd_portador = 0 then ''
      else
        isnull(pt.nm_portador, 'Sem Portador')
      end as varchar(30)) as nm_portador,
      dcc.pc_centro_custo,
      dcc.vl_centro_custo, 
      dpf.pc_plano_financeiro, 
      dpf.vl_plano_financeiro,

			case when isnull(dpf.vl_plano_financeiro,0) <> 0 then
				'**Rateio**' else
				case when isnull(dcc.vl_centro_custo,0) <> 0 then
					'**Rateio**' else '' end end   as Rateio,

  --    case when isnull(dcc.vl_centro_custo,0) <> 0 then
		--'**Rateio**'
	 -- else									   
  --       cc.nm_centro_custo
  --    end                                          as nm_centro_custo,

      case when isnull(d.cd_centro_custo,0)<>0 then
        cc.nm_centro_custo

      else
        case when exists ( select top 1 dpcc.cd_documento_pagar from Documento_pagar_centro_custo dpcc
                           where
                              dpcc.cd_documento_pagar = d.cd_documento_pagar ) 
         then '** Rateio de Centro de Custo **' else '' end

     
      end                                          as nm_centro_custo,

      d.dt_vencimento_documento,
      d.vl_multa_documento,
      d.vl_outros_documento,
      isnull(pg.ic_zera_tipo_pagamento,'N') as ic_zera_tipo_pagamento,
      max(cab.nm_conta_banco)               as nm_conta_banco,
      max(b.cd_numero_banco)                as cd_numero_banco,
      max(ag.cd_numero_agencia_banco)       as cd_numero_agencia,
      max(p.nm_obs_documento_pagar)         as nm_obs_documento_pagar,
      max(pco.cd_conta_reduzido)            as cd_conta_reduzido,

	  case when isnull(efd.nm_fantasia_empresa,'') <> '' then
	    isnull(efd.nm_fantasia_empresa,'')
      else
        case when isnull(efd.nm_fantasia_empresa,'') = ''
          then case when isnull(efn.nm_fantasia_empresa,'') = ''
               then ee.nm_fantasia_empresa
               else isnull(efn.nm_fantasia_empresa,'')
             end
         end 
      end                                 as nm_fantasia_empresa,
	  max(pco.nm_conta)                   as nm_conta_contabil
     
	 -- case when isnull(dpe.cd_documento_pagar,0)>0 and isnull(dpe.cd_empresa,0)>0 then
	 --   isnull(efd.nm_fantasia_empresa,'')
  --    else
  --    case when isnull(efd.nm_fantasia_empresa,'') = ''
  --      then case when isnull(efn.nm_fantasia_empresa,'') = ''
  --             then ee.nm_fantasia_empresa
  --             else isnull(efn.nm_fantasia_empresa,'')
  --           end
  --      else isnull(efd.nm_fantasia_empresa,'')
		--end
  --    end                                 as nm_fantasia_empresa

--select * from documento_pagar_pagamento (cd_conta_banco )
--select * from conta
--select * from conta_agencia_banco
--select * from banco
--select * from agencia_banco

    into
     #aux_documento_pago_relatorio

    from  
      documento_pagar d                           with (nolock) 
      left outer join documento_pagar_pagamento p with (nolock) on p.cd_documento_pagar     = d.cd_documento_pagar 
      left outer join tipo_conta_pagar t          with (nolock) on t.cd_tipo_conta_pagar    = d.cd_tipo_conta_pagar
      left outer join tipo_pagamento_documento pg with (nolock) on pg.cd_tipo_pagamento     = p.cd_tipo_pagamento 

      left outer join Nota_Entrada e              with (nolock) on d.cd_nota_fiscal_entrada = cast(e.cd_nota_entrada as varchar) and  
                                                                   d.cd_fornecedor          = e.cd_fornecedor                    and  
                                                                   d.cd_serie_nota_fiscal   = e.cd_serie_nota_fiscal
      left outer join conta_contabil ccont	      with(nolock) on ccont.cd_conta_contabil   = e.cd_conta_contabil
                                                                                
                                                                   --d.cd_operacao_fiscal     = e.cd_operacao_fiscal

--       left outer join Operacao_fiscal opf         with (nolock) on opf.cd_operacao_fiscal   = e.cd_operacao_fiscal               and
--                                                                    isnull(opf.ic_comercial_operacao,'N') = 'S'

      left outer join Tipo_Conta_Pagar tcp        with (nolock) on d.cd_tipo_conta_pagar = tcp.cd_tipo_conta_pagar 
      left outer join Loja l                      with (nolock) on l.cd_loja             = d.cd_loja  
      left outer join Portador pt                 with (nolock) on (pt.cd_portador       = d.cd_portador) 
      left outer join Documento_pagar_centro_custo dcc on case when @ic_rateio = 0 then 0 else dcc.cd_documento_pagar end = d.cd_documento_pagar 
      left outer join Documento_pagar_plano_financ dpf on case when @ic_rateio = 0 then 0 else dpf.cd_documento_pagar end = d.cd_documento_pagar 
      left outer join centro_custo cc             with (nolock) on cc.cd_centro_custo      = IsNull(dcc.cd_centro_custo,d.cd_centro_custo) 
      left outer join Plano_Financeiro pf         with (nolock) on pf.cd_plano_financeiro = IsNull(dpf.cd_plano_financeiro , d.cd_plano_financeiro )
      left outer join Conta_Agencia_Banco cab     with (nolock) on cab.cd_conta_banco  = p.cd_conta_banco
      left outer join Banco b                     with (nolock) on b.cd_banco          = cab.cd_banco
      left outer join Agencia_Banco ag            with (nolock) on ag.cd_agencia_banco = cab.cd_agencia_banco
      left outer join Empresa_Diversa z           with (nolock) on z.cd_empresa_diversa = d.cd_empresa_diversa
      left outer join Funcionario     k           with (nolock) on k.cd_funcionario         = d.cd_funcionario
      left outer join Contrato_Pagar  w           with (nolock) on w.cd_contrato_pagar      = d.cd_contrato_pagar

      left outer join vw_destinatario vw          with (nolock) on vw.cd_tipo_destinatario  = isnull(d.cd_tipo_destinatario,2) and
                                                                   vw.cd_destinatario       = d.cd_fornecedor
           
      left outer join Tipo_Destinatario td        with (nolock) on td.cd_tipo_destinatario  = case when isnull(d.cd_tipo_destinatario,2)>0 
                                                                                              then
                                                                                                d.cd_tipo_destinatario
                                                                                              else
                                                                                                vw.cd_tipo_destinatario
                                                                                              end

     left outer join plano_conta pco                with (nolock) on pco.cd_conta             = pf.cd_conta
	 left outer join documento_pagar_empresa dpe    with (nolock) on dpe.cd_documento_pagar   = d.cd_documento_pagar
	 left outer join empresa_faturamento efd        with (nolock) on efd.cd_empresa           = dpe.cd_empresa

     left outer join egisadmin.dbo.empresa ee      with (nolock) on ee.cd_empresa             = isnull(d.cd_empresa,@cd_empresa)

     --left outer join Documento_pagar_empresa dpe   with (nolock) on dpe.cd_documento_pagar   = d.cd_documento_pagar
     --left outer join empresa_faturamento efd       with (nolock) on efd.cd_empresa           = dpe.cd_empresa

     left outer join nota_entrada_empresa nee      with (nolock) on d.cd_nota_fiscal_entrada = cast(nee.cd_nota_entrada as varchar) and  
                                                                    d.cd_fornecedor          = nee.cd_fornecedor and  
                                                                    d.cd_serie_nota_fiscal   = nee.cd_serie_nota_fiscal 

     left outer join empresa_faturamento efn       with (nolock) on efn.cd_empresa           = nee.cd_empresa
      
     where  
      isnull(d.cd_documento_pagar,0)>0    
	  and
      d.dt_cancelamento_documento is null
	  --and
	  --p.vl_pagamento_documento > 0
	  and  
      p.dt_pagamento_documento between @dt_inicial and @dt_final  

      and

      isnull(d.cd_portador,0) = (case isnull(@cd_portador,0) 
				 when 0 then 
					isnull(d.cd_portador,0)
			      	 else 
					isnull(@cd_portador,0) 
				 end)

      and

      IsNull(IsNull(dpf.cd_plano_financeiro , d.cd_plano_financeiro ),0) = ( case when IsNull(@cd_plano_financeiro,0) = 0 then
									IsNull(IsNull(dpf.cd_plano_financeiro , d.cd_plano_financeiro ),0) else
 								    @cd_plano_financeiro end ) 

      and

      IsNull(IsNull(dcc.cd_centro_custo,d.cd_centro_custo),0) = ( case when IsNull(@cd_centro_custo,0) = 0 then
							  Isnull(IsNull(dcc.cd_centro_custo,d.cd_centro_custo),0) else
							  @cd_centro_custo end ) 
      and
  
      isnull(cd_lote_pagar,0)=0                               --Documento com Lote não pode entrar......

	 GROUP BY
	  d.cd_documento_pagar,
      d.cd_empresa_diversa,
      d.cd_favorecido_empresa,
      d.cd_contrato_pagar,
      d.cd_funcionario,
      d.nm_fantasia_fornecedor,
	  d.cd_centro_custo,
	  d.cd_plano_financeiro,
      t.sg_tipo_conta_pagar,
      d.cd_identificacao_document,
      pg.sg_tipo_pagamento,
      p.cd_identifica_documento,
      p.cd_item_pagamento,
      p.vl_pagamento_documento,
      p.vl_juros_documento_pagar,
      p.vl_desconto_documento,
      p.vl_abatimento_documento,
      tcp.ic_tipo_bordero,
      d.dt_emissao_documento_paga,
      e.dt_receb_nota_entrada,
      pf.cd_mascara_plano_financeiro,
      pf.nm_conta_plano_financeiro,
      l.nm_fantasia_loja,
      p.dt_pagamento_documento,
      pt.nm_portador,
      dcc.pc_centro_custo,
      dcc.vl_centro_custo, 
      dpf.pc_plano_financeiro, 
      dpf.vl_plano_financeiro,
      cc.nm_centro_custo,
      d.dt_vencimento_documento,
      d.vl_multa_documento,
      d.vl_outros_documento,              
      pg.ic_zera_tipo_pagamento,
	  p.vl_outros_pagamento,
    efd.nm_fantasia_empresa,
    efn.nm_fantasia_empresa,
    ee.nm_fantasia_empresa

    order by   
      (case when @cd_portador >= 0 then pt.nm_portador  end),
     	p.dt_pagamento_documento desc ,  
        vl_total                 desc  option(recompile)
	
		--select * from #aux_documento_pago_relatorio return

------------------------------------------------------------------------------------------------------------
declare @vl_pagamento_documento_total       float = 0 
declare @vl_juros_documento_pagar_total     float = 0 
declare @vl_desconto_documento_total        float = 0 
declare @vl_outros_documento_total          float = 0 
declare @vl_abatimento_documento_total      float = 0 
declare @vl_multa_documento_total           float = 0 
declare @vl_total_geral                     float = 0 
declare @qt_documento                       int = 0 
-----------------------------------------------------------------------------------------------------------
select 
@vl_pagamento_documento_total   = sum(vl_pagamento_documento),
@vl_juros_documento_pagar_total = sum(vl_juros_documento_pagar),
@vl_desconto_documento_total    = sum(vl_desconto_documento),
@vl_outros_documento_total      = sum(vl_outros_documento),
@vl_abatimento_documento_total  = sum(vl_abatimento_documento),
@vl_multa_documento_total       = sum(vl_multa_documento),
@vl_total_geral                 = sum(vl_total),
@qt_documento                   = count(cd_identificacao_document)
	
from #aux_documento_pago_relatorio
------------------------------------------------------------------------------------------------------------
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #aux_documento_pago_relatorio  
  return  
 end  
--------------------------------------------------------------------------------------------------------------
set @html_geral = '    <div class="section-title">
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p> 
        <p style="display: inline; text-align: center; padding: 25%;">
            Documentos Pagos
        </p>
    </div>
	<div>
    <table>  
       <tr>
		  <th>Data</th>
		  <th>Favorecido</th>
		  <th>Conta</th>
		  <th>Documento</th>
		  <th>Pagamento </th>
		  <th>Emissão</th>
		  <th>Entrada</th>
		  <th>Vencimento</th>
		  <th>Banco/Conta/Ag</th>
		  <th>Valor</th>
		  <th>Juros</th>
		  <th>Desc.</th>
		  <th>Acréssimo</th>
		  <th>Abat</th>
		  <th>Multa</th>
		  <th>Total Pago</th>
		  <th>Plano</th>
		  <th>Conta Contabil</th>
		</tr>'
					   
--------------------------------------------------------------------------------------------------------------
DECLARE @id int = 0 

WHILE EXISTS (SELECT TOP 1 cd_controle FROM #aux_documento_pago_relatorio)
BEGIN
    SELECT TOP 1
        @id                          = cd_controle,
       
 
       @html_geral = @html_geral +
          '<tr>
		    <td class="tamanho">'+isnull(dbo.fn_data_string(dt_pagamento_documento),'')+'</td>
		    <td style="text-align: left;">'+ISNULL(nm_favorecido,'')+'</td>
            <td class="tamanho">'+iSNULL(sg_tipo_conta_pagar,'')+ '</td>
			<td class="tamanho">'+ISNULL(cd_identificacao_document,'')+ '</td>
			<td class="tamanho">'+cast(ISNULL(sg_tipo_pagamento,'')as nvarchar(20)) + '</td>
			<td class="tamanho">'+isnull(dbo.fn_data_string(dt_emissao_documento_paga),'')+'</td>
			<td class="tamanho">'+isnull(dbo.fn_data_string(dt_recebimento),'')+'</td>
			<td class="tamanho">'+isnull(dbo.fn_data_string(dt_vencimento_documento),'')+'</td>
			<td class="tamanho">'+cast(ISNULL(cd_numero_banco,0)as nvarchar(20)) + ' / '+ISNULL(nm_conta_banco, 0)+ ' / '+cast(ISNULL(cd_numero_agencia,0)as nvarchar(20)) + '</td>
			<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(vl_pagamento_documento),0)as nvarchar(20)) + '</td>
			<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(vl_juros_documento_pagar),0)as nvarchar(20)) + '</td>
			<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(vl_desconto_documento),0)as nvarchar(20)) + '</td>
			<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(vl_outros_documento),0)as nvarchar(20)) + '</td>
			<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(vl_abatimento_documento),0)as nvarchar(20)) + '</td>
			<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(vl_multa_documento),0)as nvarchar(20)) + '</td>
			<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(vl_total),0)as nvarchar(20)) + '</td>
			<td class="tamanho">'+ISNULL(nm_conta_plano_financeiro,'')+ '</td> 
			<td class="tamanho">'+ISNULL(nm_conta_contabil,'')+ '</td>
        </tr>'
		from #aux_documento_pago_relatorio
    DELETE FROM #aux_documento_pago_relatorio WHERE cd_controle = @id
END
--------------------------------------------------------------------------------------------------------------------




set @html_rodape ='
	<tr >
		<td class="tamanho">Total</td>
		<td class="tamanho"></td>
		<td class="tamanho"></td>
		<td class="tamanho"></td>
		<td class="tamanho"></td>
		<td class="tamanho"></td>
		<td class="tamanho"></td>
		<td class="tamanho"></td>
		<td class="tamanho"></td>
		<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(@vl_pagamento_documento_total),0)as nvarchar(20)) + '</td>
		<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(@vl_juros_documento_pagar_total),0)as nvarchar(20)) + '</td>
		<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(@vl_desconto_documento_total),0)as nvarchar(20)) + '</td>
		<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(@vl_outros_documento_total),0)as nvarchar(20)) + '</td>
		<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(@vl_abatimento_documento_total),0)as nvarchar(20)) + '</td>
		<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(@vl_multa_documento_total),0)as nvarchar(20)) + '</td>
		<td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_geral),0)as nvarchar(20)) + '</td>
		<td class="tamanho"></td>
		<td class="tamanho"></td>
	</tr>
	</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
	</div>
	<div class="section-title">
     <p>Total de Documentos: '+cast(isnull(@qt_documento,0)as nvarchar(10))+'</p>
    </div>
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
--exec pr_egis_relatorio_documento_pagos 231,''
------------------------------------------------------------------------------
