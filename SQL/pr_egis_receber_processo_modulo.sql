--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_receber_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_receber_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_receber_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_receber_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_receber_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_receber_processo_modulo
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Egis
--                   Modelo de Procedure com Processos
--
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_receber_processo_modulo
------------------------
@json nvarchar(max) = ''
------------------------------------------------------------------------------
--with encryption


as

-- ver nível atual
--SELECT name, compatibility_level FROM sys.databases WHERE name = DB_NAME();

-- se < 130, ajustar:
--ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130;

--return

--set @json = isnull(@json,'')

 SET NOCOUNT ON;
 SET XACT_ABORT ON;

 BEGIN TRY
 
 /* 1) Validar payload - parameros de Entrada da Procedure */
 IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON inválido ou vazio em @json.', 1;

 /* 2) Normalizar: aceitar array[0] ou objeto */
 IF JSON_VALUE(@json, '$[0]') IS NOT NULL
            SET @json = JSON_QUERY(@json, '$[0]'); -- pega o primeiro elemento


set @json = replace(
             replace(
               replace(
                replace(
                  replace(
                    replace(
                      replace(
                        replace(
                          replace(
                            replace(
                              replace(
                                replace(
                                  replace(
                                    replace(
                                    @json, CHAR(13), ' '),
                                  CHAR(10),' '),
                                ' ',' '),
                              ':\\\"',':\\"'),
                            '\\\";','\\";'),
                          ':\\"',':\\\"'),
                        '\\";','\\\";'),
                      '\\"','\"'),
                    '\"', '"'),
                  '',''),
                '["','['),
              '"[','['),
             ']"',']'),
          '"]',']') 


declare @cd_empresa                 int
declare @cd_parametro               int
declare @cd_documento               int = 0
declare @cd_item_documento          int
declare @cd_usuario                 int = 0 
declare @dt_hoje                    datetime
declare @dt_inicial                 datetime 
declare @dt_final                   datetime
declare @cd_ano                     int = 0
declare @cd_mes                     int = 0
declare @cd_modelo                  int = 0
declare @cd_documento_receber       int = 0
declare @vl_saldo_documento         decimal(25,2) = 0.00
declare @vl_documento_receber       decimal(25,2) = 0.00
declare @cd_identificacao           varchar(25)   = ''
declare @StatusDocumento            nvarchar(max) = ''
declare @cd_status_documento        int           = 0
declare @dt_status_documento        datetime      = getdate()
declare @nm_cor                     varchar(60)   = ''
declare @cd_moeda                   int           = 1
declare @vl_moeda                   decimal(25,4) = 1.00
declare @vl_dolar                   decimal(25,4) = 1.00
declare @ic_codigo_cliente          char(1)       = 'N'
declare @cd_cliente                 int           = 0
declare @ic_tipo_filtro             char(1)       = 'V'
declare @ic_filtra_selecao          char(1)       = 'N'
declare @ic_tipo_consulta           char(1)       = 'T'
declare @nm_destinatario            varchar(60)   = ''
declare @cd_pedido_venda            int           = 0
declare @cd_banco_documento_recebe  varchar(30)   = ''
declare @cd_nota_saida              int           = 0
declare @cd_remessa_banco           int           = 0
declare @ic_parametro               int           = 0
declare @cd_cliente_grupo           int           = 0
declare @cd_vendedor                int           = 0
declare @cd_conta_banco             int           = 0
declare @cd_portador                int           = 0

----------------------------------------------------------------------------------------------------------------
declare @dados_registro           nvarchar(max) = ''
declare @dados_modal              nvarchar(max) = ''
----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------

set @cd_empresa        = 0
set @cd_parametro      = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano = year(getdate())
set @cd_mes = month(getdate())  

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end


--tabela
--select ic_sap_admin, * from Tabela where cd_tabela = 5287

select                     

 1                                                   as id_registro,
 IDENTITY(int,1,1)                                   as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
 valores.[value]                                     as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

--------------------------------------------------------------------------------------------

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_modelo              = valor from #json where campo = 'cd_modelo' 
select @cd_documento_receber   = valor from #json where campo = 'cd_documento_receber'
select @ic_parametro           = valor from #json where campo = 'ic_parametro'
select @cd_cliente_grupo       = valor from #json where campo = 'cd_cliente_grupo'
select @cd_cliente             = valor from #json where campo = 'cd_cliente'
select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
select @cd_portador            = valor from #json where campo = 'cd_portador'
select @cd_conta_banco         = valor from #json where campo = 'cd_conta_banco'


--------------------------------------------------------------------------------------

select @dados_registro         = valor from #json where campo = 'dados_registro'
select @dados_modal            = valor from #json where campo = 'dados_modal'


--------------------------------------------------------------------------------------
set @cd_usuario = isnull(@cd_usuario,0)
set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro         = ISNULL(@cd_parametro,0)
set @cd_documento_receber = isnull(@cd_documento_receber,0)

IF ISNULL(@cd_parametro,0) = 0
BEGIN
  select 
    'Sucesso' as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final


  RETURN;

END


-------------------------------------------------modal-----------------------------------------------------
if @dados_modal<>''
begin

  ---------------------------------------------------------
  -- 1) Monta tabela com os dados digitados no modal
  ---------------------------------------------------------
  declare
    @json_modal nvarchar(max) = ''

  set @json_modal = isnull(@dados_modal, '')

  -- Tabela com os campos/valores do modal
  declare @DadosModal table (
    id    int identity(1,1),
    campo varchar(200),
    valor nvarchar(max)
  )

  if (isnull(@json_modal, '') <> '')
  begin
    insert into @DadosModal (campo, valor)
    select
        m.[key]   as campo,
        m.[value] as valor
    from openjson(@json_modal) as m
  end

end
-----------------------------------------------------------------------------------------------------------





if @cd_parametro = 5 and @cd_documento_receber>0
begin
  select 
	@vl_documento_receber = isnull(d.vl_documento_receber,0),
	@cd_identificacao     = isnull(d.cd_identificacao,'')
  from
    documento_receber d
  where
    d.cd_documento_receber = @cd_documento_receber



  set @vl_saldo_documento = @vl_documento_receber - ( isnull((select 
                                                                     sum(isnull(vl_pagamento_documento, 0))
                                                                   - sum(isnull(vl_juros_pagamento, 0))     
                                                                   + sum(isnull(vl_desconto_documento, 0))
                                                                   + sum(isnull(vl_abatimento_documento, 0))
                                                                   - sum(isnull(vl_despesa_bancaria, 0))
                                                                   + sum(isnull(vl_reembolso_documento, 0))
                                                                   - sum(isnull(vl_credito_pendente, 0))
                                                                   from 
                                                                     Documento_Receber_Pagamento with (nolock) 
                                                                   where 
                                                                     cd_documento_receber = @cd_documento_receber), 0))
    

  update
    documento_receber
  set
    vl_saldo_documento = @vl_saldo_documento
  where
    cd_documento_receber = @cd_documento_receber
	select 'Baixa Documento: ' + isnull(@cd_identificacao,'')  as Msg
  ---------------------------------------------------------------
  return
  
end

--select * from documento_receber_pagamento 

if @cd_parametro = 6 and @cd_documento_receber>0
begin
	update
	  documento_receber
   set
     vl_saldo_documento = vl_documento_receber
   where
    cd_documento_receber = @cd_documento_receber
	
	delete from Documento_Receber_Pagamento where cd_documento_receber = @cd_documento_receber
	select 'Exclusão Documento: ' + isnull(@cd_identificacao,'')  as Msg
	return
end  


--Posição de Documentos a Receber---------------------------------------------------------------

if @cd_parametro = 10
begin

  declare @nm_status_documento varchar(80) = ''

  select * into #StatusDocumento from status_documento_financeiro
  order by
    isnull(qt_ordem_status, 999), cd_status_documento

    -- Gera o objeto JSON uma única vez--------------------------------------------------------------------

  SELECT @StatusDocumento = (
    SELECT cd_status_documento, nm_status_documento, nm_cor
    FROM status_documento_financeiro
    ORDER BY qt_ordem_status, cd_status_documento
    FOR JSON PATH
  );

  insert into documento_receber_status
  select
  d.cd_documento_receber,
  1                               as cd_status_documento,
  @cd_usuario                     as cd_usuario_inclusao,
  getdate()                       as dt_usuario_inclusao,
  @cd_usuario                     as cd_usuario,
  getdate()                       as dt_usuario,
  null                            as nm_cor,
  null                            as dt_status_documento,
  cast('ABERTO' as varchar(80))   as nm_status_documento


from
  documento_receber d

  while exists ( select top 1 cd_status_documento from #StatusDocumento)
  begin
  
  select top 1
    @cd_status_documento  = isnull(cd_status_documento,0),
    --@cd_pedido_venda = cd_pedido_venda,
    @nm_cor               = isnull(nm_cor,'grey-5'),
    @nm_status_documento  = isnull(nm_status_documento,'')
  from
    #StatusDocumento
  order by
    qt_ordem_status

  --Vencido--

  if @cd_status_documento = 2
  begin
    update
      documento_receber_status
    set 
      nm_cor              = @nm_cor,
      dt_status_documento = @dt_status_documento,
      cd_status_documento = @cd_status_documento,
      nm_status_documento = @nm_status_documento
    from
      documento_receber_status s 
      inner join documento_receber d on d.cd_documento_receber = s.cd_documento_receber
    where
      d.dt_vencimento_documento < @dt_status_documento
      and
      d.dt_cancelamento_documento is null
      and
      d.dt_devolucao_documento is null
      and
      isnull(d.vl_saldo_documento,0)>0


  end

  --Pago--
  
  if @cd_status_documento = 3
  begin
    update
      documento_receber_status
    set 
      nm_cor              = @nm_cor,
      dt_status_documento = @dt_status_documento,
      cd_status_documento = @cd_status_documento,
      nm_status_documento = @nm_status_documento
    from
      documento_receber_status s 
      inner join documento_receber d           on d.cd_documento_receber = s.cd_documento_receber
      inner join documento_receber_pagamento p on p.cd_documento_receber = d.cd_documento_receber
    where
      p.dt_pagamento_documento is not null
      and
      d.dt_cancelamento_documento is null
      and
      d.dt_devolucao_documento is null
      and
      isnull(d.vl_saldo_documento,0)=0

  end

  --Devolução--

  if @cd_status_documento = 12
  begin
    update
      documento_receber_status
    set 
      nm_cor              = @nm_cor,
      dt_status_documento = @dt_status_documento,
      cd_status_documento = @cd_status_documento,
      nm_status_documento = @nm_status_documento
    from
      documento_receber_status s 
      inner join documento_receber d on d.cd_documento_receber = s.cd_documento_receber
    where
      d.dt_devolucao_documento is not null
      

  end


  --Cancelado--
  
  if @cd_status_documento = 13
  begin
    update
      documento_receber_status
    set 
      nm_cor              = @nm_cor,
      dt_status_documento = @dt_status_documento,
      cd_status_documento = @cd_status_documento,
      nm_status_documento = @nm_status_documento
      
    from
      documento_receber_status s 
      inner join documento_receber d on d.cd_documento_receber = s.cd_documento_receber
    where
      d.dt_cancelamento_documento is not null
      

  end

  
  delete from #StatusDocumento
  where
    cd_status_documento = @cd_status_documento

end

--select * from documento_receber_status

drop table #StatusDocumento

-----------------------------------------------------------------------------------------


 select 
      --s.nm_status_documento,
      '1'                                               as A,

	  case when dt_devolucao_documento is not null then 
	     'Devolucao'
      else  
	    case when dt_cancelamento_documento is not null then 
	      'Cancelado'
	    else
         case when (isnull(d.vl_saldo_documento,0)   - isnull(d.vl_abatimento_documento,0)) = 0 or (isnull(d.vl_saldo_documento,0)<0) then 
           'Baixado'
         else
          case when (isnull(d.vl_saldo_documento,0) - isnull(d.vl_abatimento_documento,0)) > 0 and d.dt_vencimento_documento >= @dt_hoje
         then
          'Aberto'
        else
         case when (isnull(d.vl_saldo_documento,0) - isnull(d.vl_abatimento_documento,0)) >0 and d.dt_vencimento_documento < @dt_hoje then
           'Vencido'
         end     
        end
      end
	  end 
	  end                                              as nm_status_documento,

      d.cd_documento_receber,
      d.cd_identificacao,
      d.dt_emissao_documento,
      d.dt_vencimento_documento,
      d.dt_vencimento_original,
			dbo.fn_dia_util(dbo.fn_dia_util_efetivo(d.dt_vencimento_documento,'S','F', 1) + isnull(p.qt_credito_efetivo,0),'S','F') as dt_vencimento_original_fluxo,
			day(d.dt_vencimento_documento)										as dt_dia_venc,
			month(d.dt_vencimento_documento)									as dt_mes_venc,
			year(d.dt_vencimento_documento)										as dt_ano_venc,

      case when isnull(d.vl_saldo_documento,0)=0 then
        0
      else
        cast(@dt_hoje - d.dt_vencimento_documento as int)
      end                                               as qt_dia_documento,

    --Verifica a Conversão da Moeda

    --Verifica a Conversão da Moeda
    --case when isnull(drp.vl_pagamento_documento,0) = 0 then
      case when @cd_moeda <> isnull(d.cd_moeda,1) and @vl_moeda>0
      then
        (d.vl_documento_receber/@vl_moeda ) 
      else
        d.vl_documento_receber                                   
    --  end
    --else
    --  case when @cd_moeda <> isnull(d.cd_moeda,1)
    --  then
    --    (drp.vl_pagamento_documento/@vl_moeda ) 
    --  else
    --    drp.vl_pagamento_documento
                                 
    --  end   
    end                                                           as 'vl_documento_receber',

    case when cl.cd_tipo_mercado = 2 then round((case when @cd_moeda <> isnull(d.cd_moeda,1) and @vl_moeda>0
    then
      (d.vl_documento_receber/@vl_moeda ) 
    else
      d.vl_documento_receber                                   
    end) / (case when @vl_dolar>0 then @vl_dolar else 1 end ) ,2) else 0.00 end                         as 'vl_dolar',

--     case when isnull(d.vl_saldo_documento,0)>0 then
--       case when @cd_moeda <> isnull(d.cd_moeda,1) then
--          cast(str(d.vl_saldo_documento/@vl_moeda,25,2) as decimal(25,2))
--       else
--         cast(str(d.vl_saldo_documento,25,2) as decimal(25,2)) 
--       end
-- 
--       + 
--       isnull(d.vl_juros_previsto,0)                            
--       +
--       isnull(d.vl_multa_documento,0)
-- 
--       -
--       isnull(d.vl_abatimento_documento,0)             
--       -
--       case when isnull(wdr.vl_desconto_documento,0)>0 then 
--         wdr.vl_desconto_documento
--       else
--         0.00
--       end
-- 
--     end                                                       as 'vl_saldo_documento',

      case when isnull(d.vl_saldo_documento,0)>0 then  
  
        case when @cd_moeda <> isnull(d.cd_moeda,1) and @vl_moeda>0 then  
          cast(str(d.vl_saldo_documento/@vl_moeda,25,2) as decimal(25,2))  
        else  
          cast(str(d.vl_saldo_documento,25,2) as decimal(25,2))   
        end   
  
        +    
  
        isnull(d.vl_juros_previsto,0)                              
  
        +  
        isnull(d.vl_multa_documento,0)   
  
        -  
   
        isnull(d.vl_abatimento_documento,0)     
  
      else  
       0.00  
      end                                                            as 'vl_saldo_documento', 

      d.dt_cancelamento_documento,
      d.nm_cancelamento_documento,
      d.cd_modulo,      
      d.cd_banco_documento_recebe,
      cast(d.ds_documento_receber as varchar(8000)) as ds_documento_receber,
      isnull(d.ic_emissao_documento,'N')            as ic_emissao_documento,
      isnull(d.ic_boleto_documento,'N')             as ic_boleto_documento,
      isnull(d.ic_envio_documento,'N')              as ic_envio_documento,
      d.dt_envio_banco_documento,
      d.dt_contabil_documento,
      d.cd_portador,
      d.cd_tipo_cobranca,
      d.cd_cliente,
      -- elias 25/04/2004
      vw.nm_razao_social          as 'nm_razao_social_destinatario',
      case when vw.cd_tipo_pessoa = 1 then
        dbo.fn_formata_cnpj(vw.cd_cnpj)
      else
        dbo.fn_formata_cpf(vw.cd_cnpj)
      end                         as 'cd_cnpj',
      vw.cd_telefone,
      vw.cd_ddd,
      vw.nm_fantasia
	  +
      case when @ic_codigo_cliente='S'
      then
      ' ('+ltrim(rtrim(CAST(d.cd_cliente as varchar(9))))+')'   

     else
       ''
      end
 
	  as 'nm_fantasia_cliente',

      d.cd_tipo_documento,
      d.cd_pedido_venda,

      d.cd_nota_saida,

      case when isnull(ns.cd_identificacao_nota_saida,0)<>0 then
        ns.cd_identificacao_nota_saida
      else
        isnull(ns.cd_nota_saida,0) --16/09/2011-modificado para gerar com zero ! problema grid detectado windows7 somente
      end                                                   as cd_identificacao_nota_saida,
      ns.cd_serie_nota,
      ns.cd_mascara_operacao,
      ns.nm_operacao_fiscal,
      case when isnull(d.cd_vendedor,0) = 0
        then cl.cd_vendedor
        else isnull(d.cd_vendedor,0)
      end as cd_vendedor,  
      d.dt_pagto_document_receber,
      d.vl_pagto_document_receber,
      d.ic_tipo_lancamento,	-- 11/06/2002
      d.cd_tipo_liquidacao,
      d.cd_plano_financeiro,
      p.sg_portador,
      p.nm_portador,
      d.cd_usuario,
      d.dt_usuario,
      d.cd_tipo_destinatario,
      d.vl_abatimento_documento,
      d.vl_reembolso_documento,
      d.dt_devolucao_documento,
      d.nm_devolucao_documento,
      d.dt_retorno_banco_doc,
      d.ic_credito_icms_documento,
      d.ic_anuencia_documento,
      pf.cd_mascara_plano_financeiro,
      pf.nm_conta_plano_financeiro,
      d.cd_moeda,
      d.cd_loja,
      l.nm_fantasia_loja,
      u.nm_fantasia_usuario,
      cg.nm_cliente_grupo,
      cg.ic_tipo_pagamento,
      d.cd_centro_custo,
      cc.nm_centro_custo,
      (select top 1 sg_semana from semana where cd_semana = DATEPART(dw , d.dt_vencimento_documento)) as dia_semana,
      case when isnull(d.ic_boleto_documento,'N') = 'S' then 'Sim' else 'Não' end                     as sg_emissao_documento,

      --Cheque-------------------------------------------------------------------------------------------------------
      cr.nm_cheque_receber,
      cr.dt_deposito_cheque_recebe,
      dra.nm_obs_documento              as nm_obs_documento_analise,
      fp.cd_forma_pagamento,
      fp.nm_forma_pagamento,
      d.cd_conta_banco_remessa,
      vwc.conta,
      isnull(d.vl_juros_previsto,0)     as vl_juros_previsto,
      isnull(d.vl_multa_documento,0)    as vl_multa_documento,

      d.cd_empresa,

      case when isnull(efd.nm_fantasia_empresa,'') = '' 
        then case when isnull(ef.nm_fantasia_empresa,'') = ''
               then e.nm_fantasia_empresa 
               else isnull(ef.nm_fantasia_empresa,'') 
             end
        else 
		  isnull(efd.nm_fantasia_empresa,'')
      end                               as nm_fantasia_empresa,  --empresa_faturamento

      isnull(d.cd_remessa_banco,0)      as cd_remessa_banco,

      --Dados do Pagamento--------------------------------------------------------------------------------------------

      wb.dt_pagamento_documento,
      isnull(wb.vl_pagamento_documento,0) as vl_pagamento_documento,

      --Total da Soma das Parcelas

      isnull(vwp.vl_total_nota,0)                   as vl_total_parcela,
--      cast(d.ds_documento_receber as varchar(8000)) as ds_documento_receber

      td.nm_tipo_destinatario,
      vw.nm_pais,
      vw.sg_estado,
      vw.nm_cidade,
      wb.nm_tipo_liquidacao,
      snf.sg_serie_nota_fiscal,
      snf.nm_serie_nota_fiscal,
      vwd.nm_obs_devolucao,
      ------------------------------------------------Desconto-------------------------------------------------------------------------
      wdr.ic_desconto,
      wdr.dt_desconto_documento,
      wdr.vl_desconto_documento,
      wdr.nm_banco_desconto,
      wdr.nm_conta_banco_desconto,
	    --wb.vl_desconto_documento,
      wdr.vl_liquido_documento,
      isnull(p.qt_credito_efetivo,0) as qt_credito_efetivo,
      vw.Status,
      d.cd_contrato,
			d.cd_parcela_nota_saida,
      isnull(drb.cd_codigo_barra,'')                    as cd_codigo_barra,
      isnull(drb.cd_linha_digitavel,'')                 as cd_linha_digitavel,
      pcab.nm_portador                                  as nm_portador_conta,
      case when isnull(bc.nm_bandeira_cartao,'') = ''
        then isnull(bcp.nm_bandeira_cartao,'')
        else isnull(bc.nm_bandeira_cartao,'')
      end                                               as nm_bandeira_cartao,
      isnull(wb.nm_obs_documento,'')                    as nm_obs_documento,
      isnull(wb.nm_complemento,'')                      as nm_complemento,
      isnull(ra.nm_ramo_atividade,'')                   as nm_ramo_atividade,
	  isnull(ci.pc_desconto_boleto,0)                   as pc_desconto_boleto,
	  case when isnull(d.vl_saldo_documento,0)>0 and  isnull(ci.pc_desconto_boleto,0)>0 then
	     round(isnull(d.vl_saldo_documento,0) *  isnull(ci.pc_desconto_boleto,0)/100,2)
	  else
	    0.00
	  end                                               as vl_desconto_boleto,
    round(dbo.fn_juros_documento_receber(d.cd_documento_receber,@dt_hoje),2) as vl_juros_calculado,
    round(dbo.fn_multa_documento_receber(d.cd_documento_receber,@dt_hoje),2) as vl_multa_calculado,
    round(d.vl_saldo_documento,2)+
    round(dbo.fn_juros_documento_receber(d.cd_documento_receber,@dt_hoje),2)+
    round(dbo.fn_multa_documento_receber(d.cd_documento_receber,@dt_hoje),2) as vl_atualizado,
    wb.dt_credito_pagamento,
    wb.dt_pagamento_comissao,
    wb.cd_bandeira_cartao,
    mdcm.cd_minuta
	  --aqui

    from
      documento_receber d                               with (nolock)
      --left outer join documento_receber_status s        with (nolock) on s.cd_documento_receber      = d.cd_documento_receber
      inner join vw_destinatario        vw              with (nolock) on  d.cd_cliente               = vw.cd_destinatario and
                                                                          d.cd_tipo_destinatario     = vw.cd_tipo_destinatario
      left outer join portador p                        with (nolock) on  d.cd_portador              = p.cd_portador
      left outer join Plano_Financeiro pf               with (nolock) on pf.cd_plano_financeiro      = d.cd_plano_financeiro
      left outer join Loja l                            with (nolock) on l.cd_loja                   = d.cd_loja
      left outer join EgisAdmin.dbo.usuario u           with (nolock) on d.cd_usuario                = u.cd_usuario
      left outer join Cliente cl                        with (nolock) on cl.cd_cliente               = d.cd_cliente
      left outer join Cliente_grupo cg                  with (nolock) on cg.cd_cliente_grupo         = cl.cd_cliente_grupo
      left outer join Centro_Custo cc                   with (nolock) on cc.cd_centro_custo          = d.cd_centro_custo
      left outer join Cheque_Receber_Composicao crc     with (nolock) on crc.cd_documento_receber    = d.cd_documento_receber
      left outer join Cheque_Receber            cr      with (nolock) on cr.cd_cheque_receber        = crc.cd_cheque_receber
      left outer join Conta_Agencia_Banco cab           with (nolock) on cab.cd_conta_banco          = d.cd_conta_banco_remessa
      left outer join Portador pcab                     with (nolock) on pcab.cd_portador            = cab.cd_portador

      left outer join Documento_Receber_Analise dra     with (nolock) on dra.cd_documento_receber    = d.cd_documento_receber
      left outer join Documento_Receber_Boleto drb      with (nolock) on drb.cd_documento_receber    = d.cd_documento_receber
      left outer join Cliente_Informacao_Credito ci     with (nolock) on ci.cd_cliente               = cl.cd_cliente
      left outer join pedido_venda pv                   with (nolock) on pv.cd_pedido_venda          = d.cd_pedido_venda
      left outer join pedido_venda_parcela pvp          with (nolock) on pvp.cd_pedido_venda         = pv.cd_pedido_venda and
                                                                         pvp.cd_ident_parc_ped_venda = d.cd_identificacao
      left outer join Forma_Pagamento            fp     with (nolock) on fp.cd_forma_pagamento    = case when isnull(d.cd_forma_pagamento,0) = 0 then 
																																			case when isnull(pvp.cd_tipo_pagamento,0)>0 
																																 	 	 	 	 	 then pvp.cd_tipo_pagamento
																																					 else
																																					 case when isnull(pv.cd_forma_pagamento,0)>0 
																																							  then pv.cd_forma_pagamento 
																																							  else ci.cd_forma_pagamento end
																																			end
                                                                      else d.cd_forma_pagamento end
      left outer join Nota_Saida ns                     with (nolock) on ns.cd_nota_saida         = d.cd_nota_saida
      left outer join Serie_Nota_Fiscal snf             with (nolock) on snf.cd_serie_nota_fiscal = ns.cd_serie_nota
      left outer join Minuta_Despacho_Composicao mdcm   with (nolock) on mdcm.cd_nota_saida       = d.cd_nota_saida
      left outer join egisadmin.dbo.empresa e           with (nolock) on e.cd_empresa             = @cd_empresa
      --left outer join vw_baixa_documento_receber wb     with (nolock) on wb.cd_documento_receber  = d.cd_documento_receber
      left outer join vw_soma_parcela_nota vwp          with (nolock) on vwp.cd_nota_saida        = d.cd_nota_saida
      left outer join tipo_destinatario td              with (nolock) on td.cd_tipo_destinatario  = d.cd_tipo_destinatario
      left outer join vw_nota_devolucao_receber vwd     with (nolock) on vwd.cd_nota_saida        = d.cd_nota_saida
      left outer join vw_desconto_documento_receber wdr with (nolock) on wdr.cd_documento_receber = d.cd_documento_receber
      left outer join bandeira_cartao bc                with (nolock) on bc.cd_bandeira_cartao    = pvp.cd_bandeira_cartao
      left outer join ramo_atividade ra                 with (nolock) on ra.cd_ramo_atividade     = cl.cd_ramo_atividade
      left outer join empresa_faturamento ef            with (nolock) on ef.cd_empresa            = snf.cd_empresa_selecao
      left outer join documento_receber_empresa dre     with (nolock) on dre.cd_documento_receber = d.cd_documento_receber
      --left outer join empresa_faturamento efd           with (nolock) on efd.cd_empresa           = case when isnull(snf.cd_empresa_selecao,0) <> 0
	     --                                                                   then 
	     --                                                                     snf.cd_empresa_selecao 
						--												    else 
						--												      dre.cd_empresa 
						--												    end

      -- left outer join Documento_Receber_Pagamento drp   with (nolock) on drp.cd_documento_receber = d.cd_documento_receber
      left outer join (select      
                         drp.cd_documento_receber,    
                         max(drp.dt_pagamento_documento)            as dt_pagamento_documento,
                         case when @cd_empresa = 272
                           then
                             sum(isnull(drp.vl_pagamento_documento,0) - (isnull(drp.vl_desconto_documento,0) + isnull(drp.vl_abatimento_documento,0)) + isnull(drp.vl_juros_pagamento,0))
                           else
                             sum(isnull(drp.vl_pagamento_documento,0))  
                         end                                        as vl_pagamento_documento,      
                         sum(isnull(drp.vl_desconto_documento,0))   as vl_desconto_documento,      
                         max(tl.nm_tipo_liquidacao)                 as nm_tipo_liquidacao,      
                         max(isnull(drp.nm_obs_documento,''))       as nm_obs_documento,      
                         max(isnull(drp.nm_complemento,''))         as nm_complemento,  
                         max(isnull(drp.cd_conta_banco,0))          as cd_conta_banco,  
                         max(drp.dt_credito_pagamento)              as dt_credito_pagamento,
                         max(dt_pagamento_comissao)                 as dt_pagamento_comissao,
                         max(cd_bandeira_cartao)                    as cd_bandeira_cartao
                       from      
                         documento_receber_pagamento drp          with (nolock)       
                         left outer join Tipo_Liquidacao tl       with (nolock) on tl.cd_tipo_liquidacao = drp.cd_tipo_liquidacao      
                       where
                         drp.dt_pagamento_documento between case when @cd_empresa in (272,342,350) then drp.dt_pagamento_documento else @dt_inicial end 
                                                        and case when @cd_empresa in (272,342,350) then drp.dt_pagamento_documento else @dt_final   end
                         and  
                         isnull(drp.vl_pagamento_documento,0)>0  
                       group by      
                         drp.cd_documento_receber) wb on wb.cd_documento_receber  = d.cd_documento_receber
      left outer join bandeira_cartao bcp               with (nolock) on bcp.cd_bandeira_cartao   = wb.cd_bandeira_cartao
      left outer join vw_conta_corrente vwc             with (nolock) on vwc.cd_conta_banco       = case when isnull(d.cd_conta_banco_remessa,0) > 0 then  
	                                                                                                  isnull(d.cd_conta_banco_remessa,0)
																									else
																									  wb.cd_conta_banco 
																								    end

      left outer join empresa_faturamento efd           with (nolock) on efd.cd_empresa           = case when isnull(snf.cd_empresa_selecao,0) <> 0
	                                                                        then 
	                                                                          snf.cd_empresa_selecao 
																		    else 
																			  case when ISNULL(vwc.cd_empresa_faturamento,0)>0 then
																			      vwc.cd_empresa_faturamento
																			  else
																		         dre.cd_empresa 
                                                                              end
																		    end

    where 
---      d.dt_vencimento_documento           between @dt_inicial and @dt_final and


      --Carlos --> 25.02.2012--------------------------------------------------------------------------------------------------

      case when isnull(@cd_cliente,0) = 0
      then
        case when @ic_tipo_filtro = 'V' then d.dt_vencimento_documento         
        else        
         case when @ic_tipo_filtro = 'P' then wb.dt_pagamento_documento         
         else        
           d.dt_emissao_documento        
         end         
        end
      else d.dt_emissao_documento end
      between case when isnull(@cd_cliente,0) = 0 then @dt_inicial else d.dt_emissao_documento end  
	  and case when isnull(@cd_cliente,0) = 0 then @dt_final else d.dt_emissao_documento end  and
  
      case when isnull(d.cd_vendedor,0) = 0  
        then isnull(cl.cd_vendedor,0)  
        else isnull(d.cd_vendedor,0)  
      end in 
      (case when @ic_filtra_selecao = 'S'
        then (select cd_chave_filtro 
              from Filtro_selecao 
              where 
                cd_chave_filtro = case when isnull(d.cd_vendedor,0) = 0  
                                    then cl.cd_vendedor  
                                    else isnull(d.cd_vendedor,0)  
                                  end
                and
                cd_tabela = 141
                and
                cd_menu = 781
                and
                /*cd_modulo = 10
                and*/
                cd_usuario = @cd_usuario)
        else (case when isnull(d.cd_vendedor,0) = 0  
                then isnull(cl.cd_vendedor,0)  
                else isnull(d.cd_vendedor,0)  
              end)
      end)
      and

      -------------------------------------------------------------------------------------------------------------------------    
	  isnull(d.dt_cancelamento_documento,'01/01/1900') = case when (@ic_tipo_consulta = 'T') and (@cd_empresa in (342,350))
                                                           then isnull(d.dt_cancelamento_documento,'01/01/1900') 
                                                           else '01/01/1900'
                                                         end
      --d.dt_cancelamento_documento         is null
      and 
	  isnull(dt_devolucao_documento,'01/01/1900') = case when (@ic_tipo_consulta = 'T') and (@cd_empresa in (342,350))
                                                      then isnull(dt_devolucao_documento,'01/01/1900') 
                                                      else '01/01/1900'
                                                    end
      --d.dt_devolucao_documento            is null                               
      and ((IsNull(@nm_destinatario,'') = '') or ( vw.nm_fantasia like @nm_destinatario + '%' ))    
    
      --Saldo do Documento     
      and

--       cast(str(isnull(d.vl_saldo_documento,0),25,2) as decimal(25,2)) <> 
--         case when @ic_tipo_consulta = 'A' then 0 else 1.001 end 
     
      cast(str(isnull(d.vl_saldo_documento,0),25,2) as decimal(25,2)) =        
      case when isnull(@cd_cliente,0) = 0 then 
       case when @ic_tipo_consulta = 'B'         
       then 0           
       else        
         case when @ic_tipo_consulta = 'T'        
              then         
                cast(str(isnull(d.vl_saldo_documento,0),25,2) as decimal(25,2))        
              else        
                case when @ic_tipo_consulta = 'A' then        
                  case when cast(str(isnull(d.vl_saldo_documento,0),25,2) as decimal(25,2))>0 then        
                     cast(str(isnull(d.vl_saldo_documento,0),25,2) as decimal(25,2))        
                  else        
                    -1.0001         
                  end        
                end                   
              end        
       end
      else cast(str(isnull(d.vl_saldo_documento,0),25,2) as decimal(25,2)) end

       --Pesquisa pelo Pedido de Venda
       and isnull(d.cd_pedido_venda,0) = case when isnull(@cd_pedido_venda,0) = 0 then isnull(d.cd_pedido_venda,0) else isnull(@cd_pedido_venda,0) end
       --Pesquina pelo Número Bancário
       and isnull(d.cd_banco_documento_recebe,'') = case when @cd_banco_documento_recebe = '' then isnull(d.cd_banco_documento_recebe,'') else isnull(@cd_banco_documento_recebe,'') end 
       --Pesquisa pela Nota de Saída
       and isnull(d.cd_nota_saida,0)    = case when isnull(@cd_nota_saida,0) = 0 then isnull(d.cd_nota_saida,0) else isnull(@cd_nota_saida,0) end
       --Remessa
       and isnull(d.cd_remessa_banco,0) = case when isnull(@cd_remessa_banco,0) = 0 then isnull(d.cd_remessa_banco,0) else isnull(@cd_remessa_banco,0) end
       --Cliente
       --Cliente        
       and isnull(d.cd_cliente,0) = case when isnull(@cd_cliente,0) = 0 then isnull(d.cd_cliente,0) else isnull(@cd_cliente,0) end
       and isnull(d.cd_tipo_destinatario,0) = case when isnull(@cd_cliente,0) = 0 then isnull(d.cd_tipo_destinatario,0) else 1 end

   order by
      d.dt_vencimento_documento desc option(recompile)




  ---------------------------------------------------
  return

end


--Liberação de Crédito

if @cd_parametro = 20
begin
  --exec pr_liberacao_credito_pedido
  exec pr_liberacao_credito_pedido 1 ,0,0 ,0, '12/01/2025', '12/31/2025', null, 0
  return
end

--Baixa em Lote--
--Consulta--

if @cd_parametro = 50
begin

  set @ic_parametro      = 0 --isnull(@ic_parametro,0)
  set @cd_cliente_grupo  = isnull(@cd_cliente_grupo,0)
  set @cd_cliente        = isnull(@cd_cliente,0)
  set @cd_vendedor       = isnull(@cd_vendedor,0)

  exec pr_consulta_documentos_receber_lote @dt_inicial, @dt_final,@ic_parametro,@cd_cliente_grupo,@cd_cliente,@cd_vendedor

  return

end


 --Baixa em Lote---

 if @cd_parametro = 60
 begin

   --Dados do Modal----------------------------------------

   declare 
     @dt_baixa_documento         date,
     @cd_tipo_liquidacao          int           = 0,
     @vl_desconto                numeric(15,2) = 0.00,
     @ic_tipo_data_pagamento     char(1)       = 'S',
     @ic_estorno                 char(1)       = 'N',
     @cd_tipo_caixa              int           = 0,
     
     @nm_identificacao_pagamento varchar(30)   = '',
     @cd_banco                   int           = 0



     -------------------------------------------------------------------------
     select @dt_baixa_documento          = try_convert(date, valor)        from @DadosModal where campo = 'dt_baixa_documento'
     select @ic_estorno                  = try_convert(char(1), valor)     from @DadosModal where campo = 'ic_estorno'
     select @ic_tipo_data_pagamento      = try_convert(char(1), valor)     from @DadosModal where campo = 'ic_tipo_data_pagamento'
     select @nm_identificacao_pagamento  = try_convert(varchar(30), valor) from @DadosModal where campo = 'nm_identificacao_pagamento'
     select @cd_tipo_liquidacao          = try_convert(int, valor)         from @DadosModal where campo = 'nm_tipo_liquidacao'
     select @cd_tipo_caixa               = try_convert(int, valor)         from @DadosModal where campo = 'nm_tipo_caixa'
     select @cd_conta_banco              = try_convert(int, valor)         from @DadosModal where campo = 'nm_conta_banco'


     if @cd_conta_banco>0
     begin
       select @cd_banco = cd_banco
       from
         conta_agencia_banco
       where
         cd_conta_banco = @cd_conta_banco

     end
     ------------------------------------------------------------------------

     /*
    select
      1 as id_registro,
      IDENTITY(int,1,1) as id,
      valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,
      valores.[value] as valor
into #jsonDados
from openjson(@dados_registro) root
cross apply openjson(root.value) valores
   
   */

   -------------------------------------------------------------------
   -- 1) Validar se veio algo em dados_registro
   -------------------------------------------------------------------
   if NULLIF(@dados_registro, N'') IS NULL
   begin
       select 'Nenhum registro selecionado (dados_registro vazio).' as Msg
       return
   end

   if ISJSON(@dados_registro) <> 1
   begin
       select 'Lista de registros inválida em dados_registro.' as Msg
       return
   end

   -------------------------------------------------------------------
   -- 2) Quebrar o JSON de dados_registro
   --    Exemplo de JSON: 
   --    [ {"cd_documento_pagar": 111}, {"cd_documento_pagar": 222} ]
   -------------------------------------------------------------------
   if object_id('tempdb..#sel') is not null
       drop table #sel

   select
       IDENTITY(int,1,1)           as id,
       j.cd_documento_receber
   into #sel
   from openjson(@dados_registro) with (
           cd_documento_receber int '$.cd_documento_receber'
        ) as j



   -------------------------------------------------------------------
   -- 3) Aqui a regra de NEGÓCIO da baixa em lote
   --    Exemplo: só mostrar quais documentos chegaram
   -------------------------------------------------------------------
   --select * from #sel  -- debug

   --documento_receber_pagamento

      

   select 
     d.cd_documento_receber,
     1    as cd_item_documento_receber,
     case when @ic_tipo_data_pagamento='S' then
       d.dt_vencimento_documento
     else
       @dt_baixa_documento
     end                               as dt_pagamento_documento,
     d.vl_saldo_documento              as vl_pagamento_documento,
  
     0.00                              as vl_juros_pagamento,
     0.00                              as vl_desconto_documento,
     0.00                              as vl_abatimento_documento,
     0.00                              as vl_despesa_bancaria,
     null                              as cd_recibo_documento,
     null                              as ic_tipo_abatimento,
     null                              as ic_tipo_liquidacao, --select top 1000 ic_tipo_liquidacao, * from documento_receber_pagamento order by dt_pagamento_documento desc
     null                              as vl_reembolso_documento,
     null                              as vl_credito_pendente,
     'N'                               as ic_desconto_comissao,
     @cd_usuario                       as cd_usuario,
     getdate()                         as dt_usuario,
     cast('Baixa em Lote' as varchar)  as nm_obs_documento,
     null                              as dt_fluxo_doc_rec_pagament,
     null                              as dt_fluxo_doc_rec_pagto,
     null                              as dt_pagto_contab_documento,     
     @cd_tipo_liquidacao               as cd_tipo_liquidacao, --select * from tipo_liquidacao
     @cd_banco                         as cd_banco,
     @cd_conta_banco                   as cd_conta_banco,
     null                              as cd_lancamento, 
     @cd_tipo_caixa                    as cd_tipo_caixa,
     null                              as cd_lancamento_caixa,
     @dt_baixa_documento               as dt_credito_pagamento,
     'N'                               as ic_negociacao_documento,
     null                              as cd_cheque_adicao,
     'S'                               as ic_comissao_documento,
     @nm_identificacao_pagamento       as nm_complemento, 
     null                              as cd_forma_pagamento,
     @dt_baixa_documento               as dt_pagamento_comissao,
     null                              as cd_bandeira_cartao
   
     
     
   into
     #documento_receber_pagamento
   
   from
     documento_receber d
     inner join #sel s on s.cd_documento_receber = d.cd_documento_receber
   where
     d.cd_documento_receber not in ( select p.cd_documento_receber from documento_receber_pagamento p
                                   where
                                      p.cd_documento_receber = p.cd_documento_receber )


   insert into Documento_Receber_Pagamento
   select * from #documento_Receber_pagamento
   
   update
     documento_receber
   set
     vl_saldo_documento = 0.00
   from
     documento_receber d
     inner join #sel s on s.cd_documento_receber = d.cd_documento_receber

   -------------------------------------------------------------------
   -- 4) Mensagem de sucesso
   -------------------------------------------------------------------
   

   select 'Baixa de Lote realizada com Sucesso !' as Msg

   return

 end


 --Suspensao de Crédito

 if @cd_parametro = 70
 begin

   return

 end


 --seleção de Documentos para o Banco--------------------------------------------------
 --select * from remessa

 if @cd_parametro = 100
 begin
    
    --select @cd_conta_banco

   set @cd_documento_receber = 0
   set @cd_conta_banco       = 0

   ------------------------------------------------------------------------------
   exec pr_selecao_documento_banco
     1,       
     @dt_hoje, 
     @cd_documento_receber, 
     @cd_portador,    
     @cd_conta_banco, 
     @cd_identificacao, 
     @cd_remessa_banco
   
   ---------------------------------

   return

 end

 --Update dos Documentos Selecionados

 if @cd_parametro = 120
 begin

   --Conta Bancária
   select @cd_conta_banco              = try_convert(int, valor)         from @DadosModal where campo = 'Conta'

   --select @cd_conta_banco


   --Dados do Registro--

   -------------------------------------------------------------------
   -- 1) Validar se veio algo em dados_registro
   -------------------------------------------------------------------
   if NULLIF(@dados_registro, N'') IS NULL
   begin
       select 'Nenhum registro selecionado (dados_registro vazio).' as Msg
       return
   end

   if ISJSON(@dados_registro) <> 1
   begin
       select 'Lista de registros inválida em dados_registro.' as Msg
       return
   end

   -------------------------------------------------------------------
   -- 2) Quebrar o JSON de dados_registro
   --    Exemplo de JSON: 
   --    [ {"cd_documento_pagar": 111}, {"cd_documento_pagar": 222} ]
   -------------------------------------------------------------------
   if object_id('tempdb..#selDoc') is not null
       drop table #selDoc

   --Padrao por Campo
   /*
   select
       IDENTITY(int,1,1)           as id,
       valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
       valores.[value]                                     as valor                    
                    
   into #selDoc                    
   from                
   openjson(@dados_registro)root                    
   cross apply openjson(root.value) as valores      
   */

   select
       IDENTITY(int,1,1)           as id,
       j.cd_documento_receber
   into #selDoc
   from openjson(@dados_registro) with (
           cd_documento_receber int '$.cd_documento_receber'
        ) as j

   --
   --select * from #selDoc                    
 
   --Atualizar Todos os Documentos Selecionados---

   update
     documento_receber
   set
     cd_conta_banco_remessa = @cd_conta_banco
   from
     documento_receber d
   where
     isnull(d.cd_conta_banco_remessa,0) = 0
     and
     isnull(d.cd_remessa_banco,0) = 0
     and
     d.cd_documento_receber in ( select dr.cd_documento_receber from #selDoc dr
                                 where
                                   dr.cd_documento_receber = d.cd_documento_receber )

 


   return

 end
 

 --Estorno de Documentos Selecionados

 if @cd_parametro = 120
 begin

   return
 end
    
/* Padrão se nenhum caso for tratado */
SELECT CONCAT('Nenhuma ação mapeada para cd_parametro=', @cd_parametro) AS Msg;
   
 END TRY
    BEGIN CATCH
        DECLARE
            @errnum   INT          = ERROR_NUMBER(),
            @errmsg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @errproc  NVARCHAR(128) = ERROR_PROCEDURE(),
            @errline  INT          = ERROR_LINE(),
            @fullmsg  NVARCHAR(2048);



         -- Monta a mensagem (THROW aceita até 2048 chars no 2º parâmetro)
    SET @fullmsg =
          N'Erro em pr_egis_modelo_procedure ('
        + ISNULL(@errproc, N'SemProcedure') + N':'
        + CONVERT(NVARCHAR(10), @errline)
        + N') #' + CONVERT(NVARCHAR(10), @errnum)
        + N' - ' + ISNULL(@errmsg, N'');

    -- Garante o limite do THROW
    SET @fullmsg = LEFT(@fullmsg, 2048);

    -- Relança com contexto (state 1..255)
    THROW 50000, @fullmsg, 1;

        -- Relança erro com contexto
        --THROW 50000, CONCAT('Erro em pr_egis_modelo_procedure (',
        --                    ISNULL(@errproc, 'SemProcedure'), ':',
        --                    @errline, ') #', @errnum, ' - ', @errmsg), 1;
    END CATCH

---------------------------------------------------------------------------------------------------------------------------------------------------------    
go



------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_receber_processo_modulo
------------------------------------------------------------------------------
--exec pr_egis_receber_processo_modulo '[{"cd_parametro": 5, "cd_documento_receber": 126}]' 
--sp_helptext pr_egis_modelo_procedure

go
--select * from portador
--select * from conta_agencia_banco

/*
exec  pr_egis_receber_processo_modulo '[{"cd_parametro": 0}]'
exec  pr_egis_receber_processo_modulo '[{"cd_parametro": 1, "cd_modelo": 1}]'  
exec  pr_egis_receber_processo_modulo '[{"cd_parametro": 10, "cd_modelo": 1, "cd_usuario": 1}]'      
exec  pr_egis_receber_processo_modulo '[{"cd_parametro": 100, "cd_portador": 0, "cd_conta_banco": 0}]'                                             
*/
go
------------------------------------------------------------------------------
GO

--use egissql_329

--go
--update
--  egisadmin.dbo.menu
--set
--  ic_json_parametro = 'S',
--  cd_parametro = 10
--where
--  cd_menu = 8765

---exec  pr_egis_receber_processo_modulo '[{"cd_parametro": 10, "cd_modelo": 1, "cd_usuario": 1,"dt_inicial":"11/05/2025", "dt_final":"12/31/2025"}]'      

--use egissql_368
--go

--exec  pr_egis_receber_processo_modulo '[{"cd_parametro": 50, "ic_parametro": 1, "cd_usuario": 1,
--"dt_inicial":"11/05/2025", "dt_final":"12/31/2025"}]'      


--exec  pr_egis_receber_processo_modulo '[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 60,
--        "cd_usuario": 5034,
--        "cd_modal": 3,
--        "dados_modal": {
--            "dt_baixa_documento": "2025-12-10",
--            "nm_tipo_liquidacao": "1",
--            "nm_tipo_caixa": "1",
--            "nm_identificacao_pagamento": "123",
--            "nm_conta_banco": "1",
--            "ic_tipo_data_pagamento": "S",
--            "ic_estorno": "N"
--        },
--        "dados_registro": [
--            {
--                "cd_identificacao": "4-1/1",
--                "cd_documento_receber": 5,
--                "Emissao": "",
--                "Vencimento": "",
--                "vl_saldo_documento": 400,
--                "nm_fantasia_destinatario": "",
--                "Tipo": "",
--                "nm_razao_social": "",
--                "CNPJ": "",
--                "vl_documento_receber": 400,
--                "vl_abatimento_documento": 0,
--                "vl_juros_previsto": 0,
--                "vl_multa_documento": 0,
--                "vl_reembolso_documento": 0,
--                "nm_tipo_cobranca": "",
--                "nm_cliente_grupo": "ENGEKAR",
--                "nm_vendedor": "",
--                "nm_cidade": "SÃO BERNARDO DO CAMPO",
--                "sg_estado": "SP",
--                "cd_cliente": 1737,
--                "cd_identificacao_nota_saida": 4,
--                "sg_serie_nota_fiscal": "001",
--                "nm_condicao_pagamento": ""
--            },
--            {
--                "cd_identificacao": "6-1/1",
--                "cd_documento_receber": 4,
--                "Emissao": "",
--                "Vencimento": "",
--                "vl_saldo_documento": 907.75,
--                "nm_fantasia_destinatario": "",
--                "Tipo": "",
--                "nm_razao_social": "",
--                "CNPJ": "",
--                "vl_documento_receber": 907.75,
--                "vl_abatimento_documento": 0,
--                "vl_juros_previsto": 0,
--                "vl_multa_documento": 0,
--                "vl_reembolso_documento": 0,
--                "nm_tipo_cobranca": "",
--                "nm_cliente_grupo": "ENGEKAR",
--                "nm_vendedor": "",
--                "nm_cidade": "SÃO BERNARDO DO CAMPO",
--                "sg_estado": "SP",
--                "cd_cliente": 1737,
--                "cd_identificacao_nota_saida": 6,
--                "sg_serie_nota_fiscal": "001",
--                "nm_condicao_pagamento": ""
--            },
--            {
--                "cd_identificacao": "5-1/1",
--                "cd_documento_receber": 3,
--                "Emissao": "",
--                "Vencimento": "",
--                "vl_saldo_documento": 4000,
--                "nm_fantasia_destinatario": "",
--                "Tipo": "",
--                "nm_razao_social": "",
--                "CNPJ": "",
--                "vl_documento_receber": 4000,
--                "vl_abatimento_documento": 0,
--                "vl_juros_previsto": 0,
--                "vl_multa_documento": 0,
--                "vl_reembolso_documento": 0,
--                "nm_tipo_cobranca": "",
--                "nm_cliente_grupo": "ENGEKAR",
--                "nm_vendedor": "",
--                "nm_cidade": "SÃO BERNARDO DO CAMPO",
--                "sg_estado": "SP",
--                "cd_cliente": 1737,
--                "cd_identificacao_nota_saida": 5,
--                "sg_serie_nota_fiscal": "001",
--                "nm_condicao_pagamento": ""
--            }
--        ]
--    }
--]'

--update
--  egisadmin.dbo.menu
--  set
--   ic_json_parametro = 'S',
--   cd_form_modal = 3,
--   ic_selecao_registro = 'S'
--where
--  cd_menu = 8779


--select * from documento_receber_pagamento
--select * from documento_receber

--delete from documento_receber_pagamento
--go
--update
--  documento_receber
--  set
--    vl_saldo_documento = vl_documento_receber



/*

exec pr_egis_receber_processo_modulo '[
    {
        "ic_json_parametro": "S",
        "cd_parametro": 120,
        "cd_usuario": 5003,
        "cd_modal": 13,
        "dados_modal": {
            "dt_envio_remessa": "2025-12-23",
            "nm_portador": "ITAÚ",
            "Conta": "1"
        },
        "dados_registro": [
            {
                "nm_conta_banco": "",
                "nm_portador": "ITAÚ",
                "Vencimento": "2025-10-03",
                "Status": "S",
                "CodCliente": 1,
                "FantCliente": "VENETO ALIMENTOS LTDA",
                "Cidade": "GUARULHOS                                                   ",
                "Estado": "SP",
                "VlrDocumento": 10,
                "IdentDocumento": "10",
                "Emissao": "2025-09-28",
                "Observacao": "Vencimento < que 10 dias da emissão.",
                "cd_banco_documento_recebe": "",
                "cd_digito_bancario": "",
                "ic_emissao_documento": "N",
                "EnderecoCobrancaInvalido": "N",
                "ic_credito_suspenso": "N",
                "ic_deposito_cliente": "N",
                "ic_status_nota_saida": "",
                "DiasLimite": "",
                "VctoLimite": "",
                "ic_bloqueio_cnab_banco": "",
                "cd_remessa_banco": 0,
                "cd_pedido_venda": 0,
                "cd_identificacao_nota_saida": "",
                "dt_nota_saida": "",
                "dt_saida_nota_saida": "",
                "dt_entrega_nota_saida": "",
                "nm_forma_pagamento": "",
                "nm_razao_social": "VENETO ALIMENTOS LTDA",
                "CNPJ": "03.418.924/0001-09",
                "sg_serie_nota_fiscal": "",
                "nm_tipo_pedido": "",
                "cd_documento_receber": 1
            }
        ]
    }
]'

*/


