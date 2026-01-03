--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_pagar_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_pagar_processo_modulo
    
GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_pagar_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_pagar_processo_modulo;
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
create procedure  pr_egis_pagar_processo_modulo
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

                                 
declare @cd_empresa               int
declare @cd_parametro             int
declare @cd_documento             int = 0
declare @cd_item_documento        int
declare @cd_usuario               int 
declare @dt_hoje                  datetime
declare @dt_inicial               datetime 
declare @dt_final                 datetime
declare @cd_ano                   int = 0
declare @cd_mes                   int = 0
declare @cd_modelo                int = 0
declare @cd_documento_pagar       int = 0
declare @vl_saldo_documento       decimal(25,2) = 0.00
declare @vl_documento_pagar       decimal(25,2) = 0.00
declare @ic_tipo_filtro           char(1)       = 'V'
declare @cd_portador              int           = 0
declare @ic_tipo_consulta         char(1)       = 'A'
declare @ic_filtrar_favorecido    char(1)       = 'N'
declare @cd_identificacao         varchar(25)   = ''
declare @cd_tipo_favorecido       int           = 0
declare @ic_ordem_documento       char(1)       = 'A'
declare @cd_favorecido            int           = 0
declare @cd_empresa_faturamento   int           = 0
declare @ic_previsao_documento    char(1)       = 'N'
declare @ic_autorizacao_pagamento char(1)       = 'N'

----------------------------------------------------------------------------------------------------------------
declare @dados_registro           nvarchar(max) = ''
declare @dados_modal              nvarchar(max) = ''
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
select @cd_documento_pagar     = valor from #json where campo = 'cd_documento_pagar'

---------------------------------------------------------------------------------------------
select @dados_registro         = valor from #json where campo = 'dados_registro'
select @dados_modal            = valor from #json where campo = 'dados_modal'

----------------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro         = ISNULL(@cd_parametro,0)
set @cd_documento_pagar   = isnull(@cd_documento_pagar,0)

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

if @cd_parametro = 5 and @cd_documento_pagar>0
begin
  select @vl_documento_pagar = isnull(d.vl_documento_pagar,0)
  from
    documento_pagar d
  where
    d.cd_documento_pagar = @cd_documento_pagar



  set @vl_saldo_documento = @vl_documento_pagar - ( isnull((select 
                                                                     sum(isnull(vl_pagamento_documento, 0))
                                                                   - sum(isnull(vl_juros_documento_pagar, 0))     
                                                                   + sum(isnull(vl_desconto_documento, 0))
                                                                   + sum(isnull(vl_abatimento_documento, 0))
                                                                   --- sum(isnull(vl_despesa_bancaria, 0))
                                                                   --+ sum(isnull(vl_reembolso_documento, 0))
                                                                   --- sum(isnull(vl_credito_pendente, 0))
                                                                   from 
                                                                     Documento_Pagar_Pagamento with (nolock) 
                                                                   where 
                                                                     cd_documento_pagar = @cd_documento_pagar), 0))
    

  update
    documento_pagar
  set
    vl_saldo_documento_pagar = 0 --@vl_saldo_documento
  where
    cd_documento_pagar = @cd_documento_pagar

  ---------------------------------------------------------------
  return

end

--Exlusão Baixa
  
if @cd_parametro = 6 and @cd_documento_pagar>0
begin
	update
	  documento_pagar
   set
     vl_saldo_documento_pagar = vl_documento_pagar
   where
    @cd_documento_pagar = @cd_documento_pagar
	
	delete from Documento_Pagar_Pagamento where cd_documento_pagar = @cd_documento_pagar
	select 'Exclusão Baixa' as Msg
	return
end  



  --Baixa em Lote-----------------------------------------------------------------------

  if @cd_parametro = 10
  begin

    --Abertos---
    set @ic_tipo_consulta = 'A'

    select    
      0                                                       as 'Selecionado',    
  
      d.cd_documento_pagar,    
  
      case when isnull(d.vl_saldo_documento_pagar,0) > 0 then  
       case when d.dt_vencimento_documento<@dt_hoje then  
         'Vencido'  
       else  
         'Aberto'  
       end  
      else  
        'Baixado'  
      end                                                     as 'nm_status',  
  
      case when isnull(d.vl_saldo_documento_pagar,0) > 0 then  
         cast(@dt_hoje - d.dt_vencimento_documento as int )  
      else  
        0  
      end                                                     as  'qt_dia',  
      d.dt_vencimento_documento,    
    case when d.dt_vencimento_original is null  
    then d.dt_vencimento_documento  
    else d.dt_vencimento_original  
   end                                                     as dt_vencimento_original,  
      c.nm_tipo_conta_pagar,    
  
      --select * from empresa_diversa  
  
      cast(  
      case when (isnull(d.cd_empresa_diversa, 0) <> 0)  
      then     
         case when isnull(z.sg_empresa_diversa,'')<>''   
         then  
            z.sg_empresa_diversa  
         else   
            z.nm_empresa_diversa  
         end  
      else      
         case when (isnull(d.cd_contrato_pagar, 0) <> 0)   
         then     
             case when isnull(w.nm_fantasia_fornecedor,'')<>'' then w.nm_fantasia_fornecedor else d.nm_fantasia_fornecedor end  
         else    
            case when (isnull(d.cd_funcionario, 0) <> 0)   
            then     
               k.nm_funcionario     
            else  
              case when (isnull(d.nm_fantasia_fornecedor, '') <> '') or isnull(d.cd_tipo_destinatario,2)<>0   
              then     
                 case when isnull(d.cd_tipo_destinatario,2)=1 then  
                   vw.nm_fantasia  
                 else  
                   d.nm_fantasia_fornecedor   
                 end  
              else  
                 ''  
              end  
            end  
         end  
      end    
      as varchar(30))                             as 'cd_favorecido',    
      
      case when (isnull(d.cd_empresa_diversa, 0) <> 0) then d.cd_empresa_diversa    
           when (isnull(d.cd_contrato_pagar, 0)  <> 0) then d.cd_contrato_pagar    
           when (isnull(d.cd_funcionario, 0)     <> 0) then d.cd_funcionario    
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then d.cd_fornecedor    
      end                                         as 'cd_favorecido_chave',    
    
      case when (isnull(d.cd_empresa_diversa, 0) <> 0) then 'E'    
           when (isnull(d.cd_contrato_pagar, 0) <> 0)  then 'C'    
           when (isnull(d.cd_funcionario, 0) <> 0)     then 'U'    
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then 'F'     
      end                                         as 'ic_tipo_favorecido',    
  
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
      end as varchar(30))                            as 'nm_favorecido_empresa',  
      --documento_pagar  
  
      d.cd_favorecido_empresa,  
      cast(isnull(d.cd_identificacao_document,'') as varchar(30))   as cd_identificacao_document,    
      d.dt_emissao_documento_paga,    
  
      isnull(d.vl_documento_pagar,0)                 as 'vl_documento_pagar',    
  
      case when d.dt_cancelamento_documento is null   
      then  
        cast(str(d.vl_saldo_documento_pagar,25,2) as decimal(25,2))   
      else  
        0.00  
      end                                             as 'vl_saldo_documento_pagar',    
  
      t.nm_tipo_documento,    
  
      --Plano Financeiro---------------------------------------------------------------------------------------------------  
  
      isnull(pf.cd_plano_financeiro,0)                as 'cd_plano_financeiro',  
      pf.cd_mascara_plano_financeiro,  
  
      case when isnull(d.cd_plano_financeiro,0)<>0 then  
         pf.nm_conta_plano_financeiro  
      else  
         --Verifica se existe Rateio  
         case when exists ( select top 1 dpf.cd_documento_pagar from Documento_pagar_plano_financ dpf  
                            where dpf.cd_documento_pagar = d.cd_documento_pagar )  
         then '** Rateio de Plano Financeiro **' else '' end  
              
      end                                             as 'nm_conta_plano_financeiro',  
  
        
  
      m.sg_moeda,    
      l.nm_fantasia_loja,    
      i.nm_invoice,    
      isnull(d.vl_documento_pagar_moeda,0)           as 'vl_documento_pagar_moeda',  
      u.nm_fantasia_usuario,   
      d.dt_usuario,   
      isnull(d.vl_juros_documento,0)                 as vl_juros_documento,  
      isnull(d.vl_abatimento_documento,0)            as vl_abatimento_documento,  
      isnull(d.vl_desconto_documento,0)              as vl_desconto_documento,    
  
      ltrim(rtrim(d.nm_observacao_documento))    
      +  
      case when isnull(fo.cd_conta_banco,'')<>'' then  
        ' Conta: ' + ltrim(rtrim((cast(fo.cd_banco as varchar))))+'/'+ltrim(rtrim(fo.cd_agencia_banco))+'/'+ltrim(rtrim(fo.cd_conta_banco))  
      else  
        cast('' as varchar)  
      end  
                                                     as nm_observacao_documento,  
  
      d.dt_cancelamento_documento,  
      d.nm_cancelamento_documento,    
      pt.nm_portador,  
  
      --Busca Data de Entrada da Nota Fiscal   
      --Carlos 27.04.2007  
--Fabiano 06.11.2020 -- Problema na EXSTO -- Comentado até solucionar.  
      ( Select Top 1  
          ne.dt_receb_nota_entrada   
        from  
          Nota_Entrada ne with (nolock)             
        Where  
          d.cd_nota_fiscal_entrada = cast(ne.cd_nota_entrada as varchar) and  
          d.cd_fornecedor                       = ne.cd_fornecedor   and  
          d.cd_serie_nota_fiscal                = ne.cd_serie_nota_fiscal ) as dt_rem,  
   
--       ( Select Top 1  
--           isnull(ner.dt_rem,ne.dt_receb_nota_entrada)   
--         from  
--           Nota_Entrada_Parcela nep  
--   
--           left outer join Nota_Entrada_Registro ner on cast(d.cd_nota_fiscal_entrada as int ) = ner.cd_nota_entrada and  
--                                                        d.cd_fornecedor = ner.cd_fornecedor and  
--                                                        nep.cd_serie_nota_fiscal = ner.cd_serie_nota_fiscal  
--   
--           left outer join Nota_Entrada ne           on cast(d.cd_nota_fiscal_entrada as int) = ne.cd_nota_entrada and  
--                                                        d.cd_fornecedor          = ne.cd_fornecedor   and  
--                                                        d.cd_serie_nota_fiscal   = ne.cd_serie_nota_fiscal  
--   
--         Where  
--           d.cd_documento_pagar = nep.cd_documento_pagar  
--       )                              as dt_rem,  
  
      isnull(d.cd_moeda,0)                            as 'cd_moeda',  
      sd.nm_situacao_documento,  
      isnull(d.cd_portador,0)                         as 'cd_portador',  
      isnull(d.cd_tipo_conta_pagar,0)                 as 'cd_tipo_conta_pagar',  
  
      --Autorização de Pagamento-----------------------------------------------------------------------------------------  
  
      isnull(d.cd_ap,0)                               as 'cd_ap',  
      ap.dt_aprovacao_ap,      
      uap.nm_fantasia_usuario                         as 'Usuario_Aprovacao_AP',  
  
      isnull(d.cd_cheque_pagar,0)                     as 'cd_cheque_pagar',  
  
      --select * from fornecedor_adiantamento  
  
      --isnull(( select  
      --    sum ( isnull(fa.vl_adto_fornecedor,0) )   
      --  from   
      --    fornecedor_adiantamento fa with (nolock)   
      --  where  
      --    fa.cd_documento_pagar = d.cd_documento_pagar and  
      --    fa.cd_fornecedor = d.cd_fornecedor and              
      --    fa.dt_baixa_adto_fornecedor is null ),0) as 'TotalAdiantamento',  
  
  
  
          isnull(( select top 1 fa.vl_adiantamento_parcela  
            
        from   
          nota_entrada_parcela fa with (nolock)   
        where  
          fa.cd_fornecedor      = d.cd_fornecedor      
          and  
    fa.cd_ident_parc_nota_entr = d.cd_identificacao_document  
    and  
    isnull(fa.vl_adiantamento_parcela,0)>0  
    ),0)  
  
                                        as 'TotalAdiantamento',                         
  
      isnull(d.vl_multa_documento,0)               as 'vl_multa_documento',  
      isnull(d.vl_outros_documento,0)              as 'vl_outros_documento',                
      ip.nm_imposto,  
      d.nm_complemento_documento,  
  
      case when isnull(d.cd_centro_custo,0)<>0 then  
        cc.nm_centro_custo  
  
      else  
        case when exists ( select top 1 dpcc.cd_documento_pagar from Documento_pagar_centro_custo dpcc  
                           where  
                              dpcc.cd_documento_pagar = d.cd_documento_pagar )   
         then '** Rateio de Centro de Custo **' else '' end  
  
       
      end                                          as nm_centro_custo,  
  
  
      case when vw.cd_tipo_pessoa = 1 or z.cd_tipo_pessoa = 1 then    
        dbo.fn_Formata_Mascara('99.999.999/9999-99', isnull(vw.cd_cnpj,z.cd_cnpj_empresa_diversa))      
      else    
        dbo.fn_Formata_Mascara('999.999.999-99',    
                         vw.cd_cnpj)     
      end                   as cd_cnpj,   
  
  
      case when (isnull(d.cd_empresa_diversa, 0) <> 0)  
      then     
         z.nm_empresa_diversa  
      else      
         case when (isnull(d.cd_contrato_pagar, 0) <> 0)   
         then     
             w.nm_fantasia_fornecedor     
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
                   fo.nm_razao_social  
                 end  
              else  
                 ''  
              end  
            end  
         end  
      end                                   as 'nm_razao_social',    
  
 
      d.cd_pedido_importacao,  
      d.nm_ref_documento_pagar,  
      d.cd_tipo_destinatario,  
  
      case when isnull(d.cd_tipo_destinatario,2)>0 then    
        td.nm_tipo_destinatario  
      else  
        case when (isnull(d.cd_empresa_diversa, 0) <> 0) then 'Empresa Diversa'    
             when (isnull(d.cd_contrato_pagar,  0) <> 0) then 'Contrato'    
             when (isnull(d.cd_funcionario,     0) <> 0) then 'Funcionário'    
        end  
  
      end                                 as 'nm_tipo_destinatario',  
  
      d.cd_di,  
      di.nm_di,  
  
      --Dados do Pagamento-----------------------------------------------------------------  
  
      isnull(wb.vl_total_pagamento,0)  
  
   -  
  
   case when isnull(d.vl_saldo_documento_pagar,0)<=0 then  
  
      isnull(( select top 1 fa.vl_adiantamento_parcela  
            
        from   
          nota_entrada_parcela fa with (nolock)   
        where  
          fa.cd_fornecedor      = d.cd_fornecedor      
          and  
    fa.cd_ident_parc_nota_entr = d.cd_identificacao_document  
    and  
    isnull(fa.vl_adiantamento_parcela,0)>0  
    ),0)  
  
       else  
      0.00  
    end  
  
  
                                          as vl_pagamento_baixa,  
  
      ----------------------------------------------------------------------------------------------------------  
      wb.vl_juros_pagamento               as vl_juros_baixa,  
      wb.vl_desconto_documento            as vl_desconto_baixa,  
      wb.vl_abatimento_documento          as vl_abatimento_baixa,  
      wb.vl_multa_documento               as vl_multa_baixa,  
      wb.vl_outros_pagamento              as vl_outros_pagamento,  
  
      wb.dt_pagamento_documento,  
  
      tc.nm_tipo_caixa,  
      b.cd_numero_banco,  
      cab.nm_conta_banco,  
     case when isnull(b.nm_banco,'') <> ''   
      then  isnull(b.nm_banco,'') + ' - ' + isnull(cab.nm_contato_agencia_banco,'')  
      else ''  
     end                                 as nm_banco,  
  
      -- Diego - 16.05.2012 - adição do campo empresa              
  
      --e.nm_fantasia_empresa,  
  
   case when isnull(dpe.cd_documento_pagar,0)>0 and isnull(dpe.cd_empresa,0)>0 then  
     isnull(efd.nm_fantasia_empresa,'')  
      else  
      case when isnull(efd.nm_fantasia_empresa,'') = ''  
        then case when isnull(efn.nm_fantasia_empresa,'') = ''  
               then e.nm_fantasia_empresa  
               else isnull(efn.nm_fantasia_empresa,'')  
             end  
        else isnull(efd.nm_fantasia_empresa,'')  
  end  
      end                                 as nm_fantasia_empresa,  
  
      --Dados do Lote-----------------------------------------------------------------------  
  
      isnull(d.cd_lote_pagar,0)           as cd_lote_pagar,  
      isnull(lp.cd_identificacao_lote,'') as cd_identificacao_lote,  
  
      case when isnull(wb.cd_identificao_pagamento,'') <> '' then  
     isnull(wb.cd_identificao_pagamento,'')  
   else  
     isnull(d.cd_identificacao_document,'')   
   end                                      as cd_identificao_pagamento,  
      wb.dt_debito_bordero,  
  
      isnull(d.ic_previsao_documento,'N')      as ic_previsao_documento,  
      isnull(dpb.nm_codigo_barra_documento,'') as nm_codigo_barra_documento,  
    day(d.dt_vencimento_documento)           as dia_vencimento_documento,  
   month(d.dt_vencimento_documento)         as mes_vencimento_documento,  
   year(d.dt_vencimento_documento)          as ano_vencimento_documento,  
   isnull(d.cd_pedido_compra,0)             as cd_pedido_compra,  
      d.cd_nota_fiscal_entrada,  
   d.cd_serie_nota_fiscal_entr,  
      d.cd_serie_nota_fiscal_entr as nm_serie_nota_fiscal,  
   case when isnull(cc.sg_centro_custo,'')<>'' then cc.sg_centro_custo else cast(nm_centro_custo as char(10)) end as sg_centro_custo,  
    dpp.dt_programacao,  
    d.dt_selecao_documento,  
    d.dt_envio_banco,   
    isnull(d.ic_envio_documento,'N') as ic_envio_documento,   
 (select top 1 uu.nm_fantasia_usuario   
  from   
    Plano_Financeiro_Responsavel pfr    with (nolock)   
    left outer join egisadmin.dbo.usuario uu with (nolock) on uu.cd_usuario = pfr.cd_usuario_responsavel  
  where  
    pfr.cd_plano_financeiro = d.cd_plano_financeiro)  
   
 as nm_responsavel_conta  
      --(select top 1 snf.nm_serie_nota_fiscal from Serie_Nota_Fiscal snf where snf.cd_serie_nota_fiscal = cast(d.cd_serie_nota_fiscal_entr as int)) as nm_serie_nota_fiscal  
  
    --select * from fornecedor  
  
    into  
      #DocumentoPagar  
  
    from    
      Documento_Pagar d                           with (nolock)   
      left outer join vw_baixa_documento_pagar wb with (nolock) on wb.cd_documento_pagar    = d.cd_documento_pagar  
  
      left outer join tipo_caixa tc               with (nolock) on tc.cd_tipo_caixa         = wb.cd_tipo_caixa  
      left outer join conta_agencia_banco cab     with (nolock) on cab.cd_conta_banco       = wb.cd_conta_banco  
      left outer join banco b                     with (nolock) on b.cd_banco               = cab.cd_banco  
     
  
      left outer join Fornecedor fo               with (nolock) on fo.cd_fornecedor         = d.cd_fornecedor   
      left outer join Fornecedor_Contato f        with (nolock) on d.cd_fornecedor          = f.cd_fornecedor and  
                                                                   f.cd_contato_fornecedor  = 1     
  
      left outer join Tipo_conta_pagar c          with (nolock) on c.cd_tipo_conta_pagar    = d.cd_tipo_conta_pagar     
      left outer join Tipo_documento t            with (nolock) on t.cd_tipo_documento      = d.cd_tipo_documento     
  
      left outer join Plano_Financeiro pf         with (nolock) on pf.cd_plano_financeiro   = d.cd_plano_financeiro     
      left outer join Moeda m                     with (nolock) on d.cd_moeda               = m.cd_moeda    
      left outer join Loja l                      with (nolock) on l.cd_loja                = d.cd_loja     
      left outer join invoice i                   with (nolock) on i.cd_invoice             = d.cd_invoice    
      left outer join Di                          with (nolock) on di.cd_di                 = d.cd_di  
      left outer join EgisAdmin.dbo.Usuario u     with (nolock) on d.cd_usuario             = u.cd_usuario    
      left outer join Portador pt                 with (nolock) on pt.cd_portador           = d.cd_portador  
      left outer join situacao_documento_pagar sd with (nolock) on sd.cd_situacao_documento = d.cd_situacao_documento  
      left outer join Autorizacao_Pagamento ap    with (nolock) on ap.cd_ap                 = d.cd_ap  
      left outer join EgisAdmin.dbo.Usuario uap   with (nolock) on uap.cd_usuario           = ap.cd_usuario_aprovacao  
      left outer join Imposto ip                  with (nolock) on ip.cd_imposto            = d.cd_imposto  
      left outer join Centro_Custo cc             with (nolock) on cc.cd_centro_custo       = d.cd_centro_custo  
  
      left outer join Empresa_Diversa z           with (nolock) on z.cd_empresa_diversa     = d.cd_empresa_diversa  
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
  
     left outer join Lote_Pagar lp                 with (nolock) on lp.cd_lote_pagar          = d.cd_lote_pagar  
     left outer join Documento_pagar_empresa dpe   with (nolock) on dpe.cd_documento_pagar    = d.cd_documento_pagar  
     left outer join empresa_faturamento efd       with (nolock) on efd.cd_empresa            = dpe.cd_empresa  
  
     -- Diego - 16.05.2012 - adição da tabela empresa  
     left outer join egisadmin.dbo.empresa e     with (nolock) on e.cd_empresa             = isnull(d.cd_empresa,@cd_empresa)  
  
  
     left outer join Documento_pagar_Cod_Barra dpb with (nolock) on dpb.cd_documento_pagar = d.cd_documento_pagar  
     left outer join Nota_entrada ned              with (nolock) on d.cd_nota_fiscal_entrada = cast(ned.cd_nota_entrada as varchar) and    
                                                                    d.cd_fornecedor = ned.cd_fornecedor and    
                                                                    d.cd_serie_nota_fiscal = ned.cd_serie_nota_fiscal 
     left outer join nota_entrada_empresa nee      with (nolock) on d.cd_nota_fiscal_entrada = cast(nee.cd_nota_entrada as varchar) and    
                                                                    d.cd_fornecedor = nee.cd_fornecedor and    
                                                                    d.cd_serie_nota_fiscal = nee.cd_serie_nota_fiscal and
                                                                    ned.cd_operacao_fiscal = nee.cd_operacao_fiscal
     left outer join empresa_faturamento efn       with (nolock) on efn.cd_empresa         = nee.cd_empresa  
     left outer join documento_pagar_programacao dpp with(nolock) on dpp.cd_documento_pagar = d.cd_documento_pagar  
  
  
    where    
  
 
      --Carlos 17.09.2005    
      --Atual e Correto é filtrar por vencimento    
  
      case when @ic_tipo_filtro = 'V' then  
      IsNull(d.dt_vencimento_documento,'')  
      else  
       case when @ic_tipo_filtro = 'E' then  
          IsNull(d.dt_emissao_documento_paga,'')  
       else  
         case when @ic_tipo_filtro = 'P' then  
           isnull(wb.dt_pagamento_documento,'')  
         end  
       end  
      end   
  
      between case when @cd_identificacao= '' then @dt_inicial   
        else      
--                                                 case when @ic_tipo_filtro = 'V' then  
--                                                    IsNull(d.dt_vencimento_documento,'')  
--                                                 else  
--                                                    IsNull(d.dt_emissao_documento_paga,'')  
--                                                 end  
--                                               end   
      case when @ic_tipo_filtro = 'V' then  
      IsNull(d.dt_vencimento_documento,'')  
      else  
       case when @ic_tipo_filtro = 'E' then  
          IsNull(d.dt_emissao_documento_paga,'')  
       else  
         case when @ic_tipo_filtro = 'P' then  
           isnull(wb.dt_pagamento_documento,'')  
         end  
       end  
      end   
      end  
  
      and case when @cd_identificacao = '' then @dt_final    
                                              else      
  
      case when @ic_tipo_filtro = 'V' then  
      IsNull(d.dt_vencimento_documento,'')  
      else  
       case when @ic_tipo_filtro = 'E' then  
          IsNull(d.dt_emissao_documento_paga,'')  
       else  
         case when @ic_tipo_filtro = 'P' then  
           isnull(wb.dt_pagamento_documento,'')  
         end  
       end  
      end   
  
      end  
                                                 
      and     
  
      IsNull(dt_cancelamento_documento,'') = (case when (@ic_filtrar_favorecido = 'S' or @ic_tipo_consulta = 'T' or @cd_identificacao <> '') then    
                                                    IsNull(dt_cancelamento_documento,'') else    
                                                     '' end )    
      and     
  
      --Saldo do Documento  
 
  
      IsNull(cast(str(vl_saldo_documento_pagar,25,2) as decimal(25,2)),0) =   
  
      case when @ic_tipo_consulta = 'P'  
      then  
        0.00  
      else  
        case when @ic_tipo_consulta = 'T' then  
           IsNull(cast(str(vl_saldo_documento_pagar,25,2) as decimal(25,2)),0)  
        else  
         (case when @ic_filtrar_favorecido = 'S'   
               then  
                 IsNull(cast(str(vl_saldo_documento_pagar,25,2) as decimal(25,2)),0)   
               else          
                 case when @ic_tipo_consulta = 'A'  
                 then  
                   case when ( IsNull(cast(str(vl_saldo_documento_pagar,25,2) as decimal(25,2)),0)>0 or @cd_identificacao <> '' )  
                   then  
                     IsNull(cast(str(vl_saldo_documento_pagar,25,2) as decimal(25,2)),0)  
                   else  
                     -1.0001  
                   end  
                 end  
               end )    
        end   
  
      end     
    
      -- Quando é chamado pela tela de cadastro de documentos a pagar, não pode trazer documentos relacionados a borderô    
      -- quando é chamado pela tela de manutenção de documentos, chamará a todo momento.    
  
--       and     
--       not exists ( select top 1 'x'    
--                        from    
--                          Documento_Pagar x           with (nolock) inner join    
--                          Documento_Pagar_Pagamento p with (nolock) on x.cd_documento_pagar = p.cd_documento_pagar inner join    
--                          Bordero b on cast(b.cd_bordero as varchar) = p.cd_identifica_documento and p.cd_tipo_pagamento = 1     
--                        where    
--                          x.cd_documento_pagar = (case when @ic_filtrar_favorecido = 'S'  
--                                                       then 0   
--                                                       else d.cd_documento_pagar end ) )    
  
      and     
    
      IsNull(case when (isnull(d.cd_empresa_diversa, 0)      <> 0)  and IsNull(@cd_tipo_favorecido,'') <> ''    then 'E'          
                  when (isnull(d.cd_contrato_pagar, 0)       <> 0)  and IsNull(@cd_tipo_favorecido,'') <> ''    then 
                    case when IsNull(@cd_tipo_favorecido,'') = 'FO' then 'FO' else 'C' end
                  when (isnull(d.cd_funcionario, 0)          <> 0)  and IsNull(@cd_tipo_favorecido,'') <> ''    then 'F'          
                  when (isnull(d.nm_fantasia_fornecedor, '') <> '') and IsNull(@cd_tipo_favorecido,'') <> ''    then 'FO'          
                  when @ic_filtrar_favorecido = 'N' then ''          
             end,'') = IsNull(@cd_tipo_favorecido,'')           
        
       and           
          
       IsNull(case when (isnull(d.cd_empresa_diversa, 0) <> 0)       and IsNull(@cd_tipo_favorecido,'') <> '' then cast(d.cd_empresa_diversa as varchar(30))          
                   when (isnull(d.cd_contrato_pagar, 0)  <> 0)       and IsNull(@cd_tipo_favorecido,'') <> '' then 
                     case when IsNull(@cd_tipo_favorecido,'') = 'FO' then cast(d.cd_fornecedor as varchar(30)) else cast(d.cd_contrato_pagar  as varchar(30)) end           
                   when (isnull(d.cd_funcionario,    0)  <> 0)       and IsNull(@cd_tipo_favorecido,'') <> '' then cast(d.cd_funcionario     as varchar(30))          
                   when (isnull(d.nm_fantasia_fornecedor, '') <> '') and IsNull(@cd_tipo_favorecido,'') <> '' then cast(d.cd_fornecedor      as varchar(30))          
                   when @ic_filtrar_favorecido = 'N' then ''          
               end,'') = IsNull(@cd_favorecido,'')  
  
      --and    
  
      --Verificar quando for cliente--------------------------------------------------------------------------------------  
      --06.02.2015  
      --and isnull(d.cd_tipo_destinatario,0) = 2 --Fornecedor  
      --20.07.2015  
      --and isnull(d.cd_tipo_destinatario,2) = case when isnull(@cd_tipo_destinatario,0)=0 then isnull(d.cd_tipo_destinatario,2) else @cd_tipo_destinatario end  
    and
     isnull(dpe.cd_empresa,0) = case when isnull(@cd_empresa_faturamento,0) > 0 then @cd_empresa_faturamento else isnull(dpe.cd_empresa,0) end
                                                                                           
      ---------------------------------------------------------------------------------------------------------------------------------------  
      and IsNull(d.cd_identificacao_document,'') like IsNull(@cd_identificacao,'') + '%'   
      and isnull(d.cd_portador,0) = (case when isnull(@cd_portador,0) = 0 or (isnull(@cd_portador,0) =  -1) then isnull(d.cd_portador,0) else isnull(@cd_portador,0) end)   
      and isnull(d.ic_previsao_documento,'N') = case when isnull(@ic_previsao_documento,'N') = 'S' then 'S' else isnull(d.ic_previsao_documento,'N') end option(recompile)  
  
    if isnull(@ic_ordem_documento, 'A' )='R'  
    begin  
      -- print '1'   
      select   
        *  
      from  
        #DocumentoPagar    
      order by    
        nm_razao_social,          
        case when (@cd_portador = -1) or (@cd_portador > 0) then cd_portador end ,  
        dt_vencimento_documento asc,  
        vl_documento_pagar      desc,    
        cd_tipo_conta_pagar,    
        cd_favorecido,    
        cd_identificacao_document  option(recompile)  
  
    end  
  
  
    if isnull(@ic_ordem_documento, 'A' )='A'  
    begin  
      -- print '1'  
   if @ic_autorizacao_pagamento = 'S' and @cd_empresa not in (289, 63)
   begin  
     select   
          *  
        from  
          #DocumentoPagar   
       where  
         dt_aprovacao_ap is not null  
        order by    
          case when (@cd_portador = -1) or (@cd_portador > 0) then cd_portador end ,  
          nm_fantasia_empresa,  
          dt_vencimento_documento asc,  
          vl_documento_pagar      desc,    
          cd_tipo_conta_pagar,    
          cd_favorecido,    
          cd_identificacao_document option(recompile)  
   end  
   else  
   begin  
        select   
          *  
        from  
          #DocumentoPagar    
        order by    
          case when (@cd_portador = -1) or (@cd_portador > 0) then cd_portador end ,  
          nm_fantasia_empresa,  
          dt_vencimento_documento asc,  
          vl_documento_pagar      desc,    
          cd_tipo_conta_pagar,    
          cd_favorecido,    
          cd_identificacao_document option(recompile)  
      end  
    end  
    else  
    begin  
   if @ic_autorizacao_pagamento = 'S' and @cd_empresa not in (289, 63)
   begin  
     select   
          *  
        from  
          #DocumentoPagar   
      where  
         dt_aprovacao_ap is not null  
        order by    
          case when (@cd_portador = -1) or (@cd_portador > 0) then cd_portador end ,  
          dt_vencimento_documento desc,  
          vl_documento_pagar      desc,    
          cd_tipo_conta_pagar,    
          cd_favorecido,    
          cd_identificacao_document option(recompile)  
   end  
   else  
   begin  
        select   
          *  
        from  
          #DocumentoPagar        
        order by    
          case when (@cd_portador = -1) or (@cd_portador > 0) then cd_portador end ,  
          dt_vencimento_documento desc,  
          vl_documento_pagar      desc,    
          cd_tipo_conta_pagar,    
          cd_favorecido,    
          cd_identificacao_document option(recompile)  
       end  
    end  
  
    return

  end

 --Baixa em Lote---

 if @cd_parametro = 20
 begin

   --Dados do Modal----------------------------------------

   declare 
     @dt_baixa_documento         date,
     @cd_tipo_pagamento          int           = 0,
     @vl_desconto                numeric(15,2) = 0.00,
     @ic_tipo_data_pagamento     char(1)       = 'S',
     @ic_estorno                 char(1)       = 'N',
     @cd_tipo_caixa              int           = 0,
     @cd_conta_banco             int           = 0,
     @nm_identificacao_pagamento varchar(30)   = ''



     -------------------------------------------------------------------------
     select @dt_baixa_documento          = try_convert(date, valor)        from @DadosModal where campo = 'dt_baixa_documento'
     select @ic_estorno                  = try_convert(char(1), valor)     from @DadosModal where campo = 'ic_estorno'
     select @ic_tipo_data_pagamento      = try_convert(char(1), valor)     from @DadosModal where campo = 'ic_tipo_data_pagamento'
     select @nm_identificacao_pagamento  = try_convert(varchar(30), valor) from @DadosModal where campo = 'nm_identificacao_pagamento'
     select @cd_tipo_pagamento           = try_convert(int, valor)         from @DadosModal where campo = 'nm_tipo_pagamento'
     select @cd_tipo_caixa               = try_convert(int, valor)         from @DadosModal where campo = 'nm_tipo_caixa'
     select @cd_conta_banco              = try_convert(int, valor)         from @DadosModal where campo = 'nm_conta_banco'


     
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
       j.cd_documento_pagar
   into #sel
   from openjson(@dados_registro) with (
           cd_documento_pagar int '$.cd_documento_pagar'
        ) as j


   --update documento_pagar set vl_saldo_documento_pagar = vl_documento_pagar
   --delete from Documento_Pagar_Pagamento
   
   --drop table ccfsel
   --select * into ccfsel from #sel
   --select * from ccfsel
   --select * from documento_pagar_pagamento where cd_documento_pagar = 12
   --select vl_saldo_documento_pagar,* from documento_pagar where cd_documento_pagar = 12


   -------------------------------------------------------------------
   -- 3) Aqui a regra de NEGÓCIO da baixa em lote
   --    Exemplo: só mostrar quais documentos chegaram
   -------------------------------------------------------------------
   --select * from #sel  -- debug

   --documento_pagar_pagamento

   select 
     d.cd_documento_pagar,
     1    as cd_item_pagamento,
     case when @ic_tipo_data_pagamento='S' then
       d.dt_vencimento_documento
     else
       @dt_baixa_documento
     end                               as dt_pagamento_documento,
     d.vl_saldo_documento_pagar        as vl_pagamento_documento,
     @nm_identificacao_pagamento       as cd_identifica_documento,
     0.00                              as vl_juros_documento_pagar,
     0.00                              as vl_desconto_documento,
     0.00                              as vl_abatimento_documento,
     null                              as cd_recibo_documento,
     @cd_tipo_pagamento                as cd_tipo_pagamento, --select * from tipo_pagamento_documento

     cast('Baixa em Lote' as varchar)  as nm_obs_documento_pagar,
     'N'                               as ic_deposito_conta,
     @cd_usuario                       as cd_usuario,
     getdate()                         as dt_usuario,
     null                              as dt_fluxo_doc_pagar_pagto,
     @cd_conta_banco                   as cd_conta_banco,
     null                              as nm_contrato_cambio,
     null                              as dt_moeda,
     1                                 as vl_moeda,
     null                              as vl_tarifa_contrato_cambio,
     null                              as cd_fechamento_cambio,
     null                              as cd_contrato_cambio,
     1                                 as cd_moeda,
     null                              as ic_fechamento_cambio,
     null                              as cd_lancamento,
     null                              as cd_lancamento_caixa,
     @cd_tipo_caixa                    as cd_tipo_caixa,
     0.00                              as vl_multa_documento_pagamento,
     cast('' as varchar)               as nm_obs_compl_documento,
     0.00                              as vl_outros_pagamento,
     null                              as cd_item_adto_fornecedor,
     null                              as cd_conta

   into
     #documento_pagar_pagamento
   
   from
     documento_pagar d
     inner join #sel s on s.cd_documento_pagar = d.cd_documento_pagar
   where
     d.cd_documento_pagar not in ( select p.cd_documento_pagar from documento_pagar_pagamento p
                                   where
                                      p.cd_documento_pagar = p.cd_documento_pagar )

   --select * from documento_pagar_pagamento

   insert into Documento_Pagar_Pagamento
   select * from #documento_pagar_pagamento
   
   update
     documento_pagar
   set
     vl_saldo_documento_pagar = 0.00
   from
     documento_pagar d
     inner join #sel s on s.cd_documento_pagar = d.cd_documento_pagar

     --select * from documento_pagar where cd_documento_pagar = 11

   -------------------------------------------------------------------
   -- 4) Mensagem de sucesso
   -------------------------------------------------------------------
   

   select 'Baixa de Lote realizada com Sucesso !' as Msg

   return

 end

 if @cd_parametro = 999
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
--exec  pr_egis_pagar_processo_modulo
------------------------------------------------------------------------------

--sp_helptext pr_egis_modelo_procedure

go
/*
exec  pr_egis_pagar_processo_modulo '[{"cd_parametro": 0}]'
exec  pr_egis_pagar_processo_modulo '[{"cd_parametro": 1, "cd_modelo": 1}]'                                           ]'
exec  pr_egis_pagar_processo_modulo '[{"cd_parametro": 5, "cd_documento_pagar": 3308}]'                                           
exec  pr_egis_pagar_processo_modulo '[{"cd_parametro": 10, "cd_documento_pagar": 0, "dt_inicial":"01/02/2025","dt_final":"12/31/2025"}]'                                           

*/
go

--exec  pr_egis_pagar_processo_modulo '[{"cd_parametro": 10, "cd_documento_pagar": 0, "dt_inicial":"01/02/2025","dt_final":"12/31/2025"}]'                                           
--go

--exec  pr_egis_pagar_processo_modulo '[{"cd_parametro": 20, "cd_documento_pagar": 0, "dt_inicial":"01/02/2025","dt_final":"12/31/2025"}]'                                           

--payload-
--Dados do Registro--
/*
[
    {
        "cd_documento_pagar": 10,
        "nm_status": "Vencido",
        "qt_dia": 5,
        "dt_vencimento_documento": "2025-11-30",
        "nm_tipo_conta_pagar": "",
        "cd_favorecido": "PINHEIRO COM DE",
        "nm_favorecido_empresa": "",
        "cd_identificacao_document": "27106-1",
        "dt_emissao_documento_paga": "2025-11-03",
        "vl_documento_pagar": 3930,
        "vl_saldo_documento_pagar": 3930,
        "nm_tipo_documento": "Nota Fiscal",
        "cd_mascara_plano_financeiro": "",
        "nm_conta_plano_financeiro": "",
        "sg_moeda": "R$        ",
        "nm_fantasia_usuario": "",
        "dt_usuario": "2025-11-19",
        "vl_juros_documento": 0,
        "vl_abatimento_documento": 0,
        "vl_desconto_documento": 0,
        "nm_observacao_documento": "",
        "dt_cancelamento_documento": "",
        "nm_cancelamento_documento": "",
        "nm_portador": "CARTEIRA",
        "nm_situacao_documento": "Aberto",
        "TotalAdiantamento": 0,
        "nm_imposto": "",
        "nm_centro_custo": "",
        "cd_cnpj": "59.699.256/0003-43",
        "nm_razao_social": "PINHEIRO COM DE PAPEIS E EMBALAGENS LTDA",
        "nm_tipo_destinatario": "Fornecedor",
        "vl_pagamento_baixa": 0,
        "vl_juros_baixa": "",
        "vl_desconto_baixa": "",
        "vl_abatimento_baixa": "",
        "vl_multa_baixa": "",
        "vl_outros_pagamento": "",
        "dt_pagamento_documento": "",
        "nm_tipo_caixa": "",
        "nm_conta_banco": "",
        "nm_banco": "",
        "nm_fantasia_empresa": "ENGEKAR",
        "cd_lote_pagar": 0,
        "cd_identificacao_lote": "",
        "cd_identificao_pagamento": "27106-1",
        "ic_previsao_documento": "N",
        "mes_vencimento_documento": 12,
        "ano_vencimento_documento": 2025,
        "cd_pedido_compra": 0,
        "cd_nota_fiscal_entrada": "27106",
        "dt_envio_banco": "",
        "nm_responsavel_conta": ""
    },
    {
        "cd_documento_pagar": 6,
        "nm_status": "Vencido",
        "qt_dia": 5,
        "dt_vencimento_documento": "2025-11-30",
        "nm_tipo_conta_pagar": "",
        "cd_favorecido": "TSONG CHERNG",
        "nm_favorecido_empresa": "",
        "cd_identificacao_document": "11808-1",
        "dt_emissao_documento_paga": "2025-11-03",
        "vl_documento_pagar": 1086,
        "vl_saldo_documento_pagar": 1086,
        "nm_tipo_documento": "Nota Fiscal",
        "cd_mascara_plano_financeiro": "",
        "nm_conta_plano_financeiro": "",
        "sg_moeda": "R$        ",
        "nm_fantasia_usuario": "",
        "dt_usuario": "2025-11-19",
        "vl_juros_documento": 0,
        "vl_abatimento_documento": 0,
        "vl_desconto_documento": 0,
        "nm_observacao_documento": "",
        "dt_cancelamento_documento": "",
        "nm_cancelamento_documento": "",
        "nm_portador": "CARTEIRA",
        "nm_situacao_documento": "Aberto",
        "TotalAdiantamento": 0,
        "nm_imposto": "",
        "nm_centro_custo": "",
        "cd_cnpj": "02.199.454/0001-69",
        "nm_razao_social": "TSONG CHERNG IND E COM DE MAQUINAS LTDA",
        "nm_tipo_destinatario": "Fornecedor",
        "vl_pagamento_baixa": 0,
        "vl_juros_baixa": "",
        "vl_desconto_baixa": "",
        "vl_abatimento_baixa": "",
        "vl_multa_baixa": "",
        "vl_outros_pagamento": "",
        "dt_pagamento_documento": "",
        "nm_tipo_caixa": "",
        "nm_conta_banco": "",
        "nm_banco": "",
        "nm_fantasia_empresa": "ENGEKAR",
        "cd_lote_pagar": 0,
        "cd_identificacao_lote": "",
        "cd_identificao_pagamento": "11808-1",
        "ic_previsao_documento": "N",
        "mes_vencimento_documento": 12,
        "ano_vencimento_documento": 2025,
        "cd_pedido_compra": 0,
        "cd_nota_fiscal_entrada": "11808",
        "dt_envio_banco": "",
        "nm_responsavel_conta": ""
    }
]
*/

go
--use egissql_360
--go
--update
--  egisadmin.dbo.menu
--set
--  ic_json_parametro='S'
--where
--  cd_menu = 8766

--exec dbo.pr_consulta_documento_pagar  @ic_parametro=7, @dt_inicial='2020-11-01 00:00:00',@dt_final='2020-11-30 00:00:00',@cd_favorecido=NULL,@cd_tipo_conta_pagar=NULL,@ic_filtrar_favorecido='N',@cd_tipo_favorecido=NULL,@cd_identificacao=NULL,@ic_tipo_consulta='A',@ic_tipo_filtro='V'

------------------------------------------------------------------------------
GO
--select * from documento_pagar_pagamento

--update
--  documento_pagar 
--set
--  vl_saldo_documento_pagar = vl_documento_receber
--where
--  cd_documento_pagar = 111652

--select * from documento_pagar_pagamento where cd_documento_pagar = 111652

--select vl_saldo_documento_pagar from documento_pagar where cd_documento_pagar = 111652

--3308

--update
--  egisadmin.dbo.menu

--  set
--    ic_selecao_registro = 'S',
--    cd_form_modal = 1
--  where
--   cd_menu = 8766

      