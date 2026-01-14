IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_identificacao_nota_fiscal' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_identificacao_nota_fiscal
GO

CREATE VIEW vw_nfe_identificacao_nota_fiscal    
------------------------------------------------------------------------------------    
--sp_helptext vw_nfe_identificacao_nota_fiscal    
------------------------------------------------------------------------------------    
--GBS - Global Business Solution                                        2004    
------------------------------------------------------------------------------------    
--Stored Procedure : Microsoft SQL Server 2000    
--Autor(es)          : Carlos Cardoso Fernandes    
--Banco de Dados    : EGISSQL     
--    
--Objetivo          : Identificação da Nota Fiscal     
--                        para o sistema de emissão da Nota Fiscal Eletrônica    
--    
--Data                  : 04.11.2008    
--Atualização           : 22.11.2008 - Xml - Carlos Fernandes    
-- 17.06.2010 - Finalidade da Nota Fiscal Eletrônica - Carlos Fernandes    
-- 14.08.2010 - Complemento dos Campos - Carlos Fernandes     
-- 23.09.2010 - Mudança para o lay-out v2.0 - Carlos Fernandes    
-- 09.03.2011 - Verificação de Nota Referenciada - Carlos Fernandes    
-- 07.11.2011 - Acerto no conteúdo do campo hr_nota_saida - Marcelo Arimizu    
-- 18.11.2011 - Correção da nota fiscal complementar - problema na chave - Luiz/Arimizu    
-- 06.05.2013 - Verificação do campo - indPag - condição de pagamento - Carlos/Fagner    
-- 05.05.2014 - Versão 3.10 novos campos - Carlos Fernandes    
-- 16.06.2014 - Ajuste do IF sobre a Hora de Saída - Carlos Fernandes    
-- 22.10.2014 - Horário de Verão - checagem na Tabela - Carlos Fernandes    
-- 05.05.2016 - acerto da nota referenciada - Carlos Fernandes    
-- 27.01.2018 - mudança para nota fiscal 4.00 - Carlos Fernandes / Fagner Cardoso    
-- 13.06.2018 - acerto do indicador da condição de pagamento - Carlos Fernandes     
-- 02.09.2019 - Acerto campo cNF, codigo numerico nova Validação Receita - Fagner Cardoso    
-- 03.09.2019 - Acerto campo refnfe, Nova Validação Receita - Fagner Cardoso    
-- 15.02.2021 - Acerto da Hora de Saída, apenas para quando tiver validada - Carlos Fernandes/Luis Fernando    
-- 29.04.2021 - Acerto da Hora de Saída para pegar a hora do dia caso não informada - Pedro Henrique Jardim    
-- 06.07.2021 - Inclusão da Empresa Faturamento -- Fagner Cardoso    
-- 15.03.2022 - Add data de saida automaticamente conforme parametro faturamento - Pedro Jardim
-----------------------------------------------------------------------------------------------------------------    
as    
    
--select * from versao_nfe    
--select * from forma_condicao_pagamento    
--select * from serie_nota_fiscal    
    
--declare @dt_hoje as datetime    
--set @dt_hoje    = convert(datetime,left(convert(varchar,DATEADD(hour, -1, getdate()),121),10)+' 00:00:00',121)    
    
select    
  ns.cd_identificacao_nota_saida,    
  ns.cd_nota_saida,    
  ns.dt_nota_saida,    
    
  'B'                                                                                           as 'TAG',    
    
  ltrim(rtrim(cast(est.cd_ibge_estado as varchar(2))))                                          as 'cUF',    
  --ltrim(rtrim(cast(ns.cd_nota_saida as varchar(10))))                                         as 'cNF',    
--  dbo.fn_strzero(ns.cd_identificacao_nota_saida,08)                                             as 'cNF',    
  dbo.fn_strzero(ns.cd_nota_saida,08)                                             as 'cNF',    
  ltrim(rtrim(cast(ns.cd_mascara_operacao as varchar(60))))                                     as 'natOp',     
  ltrim(rtrim(cast(ns.nm_operacao_fiscal  as varchar(60))))                                     as 'DesNatOP',    
    
--  ltrim(rtrim(cast(isnull(fcp.cd_digito_forma_condicao,0) as varchar(10))))                     as 'indPag',    
-- Indicador_Forma_Pagamento    
  ltrim(rtrim(cast(isnull(ifp.cd_identificacao_nfe,0) as varchar(10))))                         as 'indPag',    
    
  --Checar na Nota Fiscal    
    
  dbo.fn_strzero(case when isnull(ns.cd_modelo_serie_nota,'')<>'' and     
                   ns.cd_modelo_serie_nota <> snf.cd_modelo_serie_nota     
  then isnull(ns.cd_modelo_serie_nota,'55') else isnull(snf.cd_modelo_serie_nota,'55') end,2)      as 'mod',    
    
  case when ns.qt_serie_nota_fiscal = 0 then    
    ltrim(rtrim(cast(isnull(ns.qt_serie_nota_fiscal,0) as varchar(3))))    
  else    
    ltrim(rtrim(cast(isnull(snf.qt_serie_nota_fiscal,0) as varchar(3))))    
  end                                                                                           as 'serie',    
    
  ltrim(rtrim(cast(ns.cd_identificacao_nota_saida as varchar(9))))                              as 'nNF',    
    
  ltrim(rtrim(replace(convert(char,ns.dt_nota_saida,102),'.','-')))                             as 'dEmi',    
    
  case when (isnull(pf.ic_atualiza_data_saida_nf,'N') = 'S') and (ns.dt_saida_nota_saida is null) then
    ltrim(rtrim(replace(convert(char,DATEADD(hour, -1, getdate()),102),'.','-')))
  else
    ltrim(rtrim(replace(convert(char,ns.dt_saida_nota_saida,102),'.','-'))) end                  as 'dSaiEnt',    
    
--FormatDateTime('YYYY-MM-DD"T"HH:MM:SS',Now)    
    
  ltrim( rtrim( dbo.fn_strzero(datepart(yyyy,ns.dt_nota_saida),4) +'-'+    
                dbo.fn_strzero(datepart(mm,ns.dt_nota_saida),2)   +'-'+    
                dbo.fn_strzero(datepart(dd,ns.dt_nota_saida),2)   +'T'+    
                --Carlos - 15.02.2021    
            
                case when isnull(ns.hr_nota_saida,'')='' or ns.dt_nota_saida<convert(datetime,left(convert(varchar,DATEADD(hour, -1, getdate()),121),10)+' 00:00:00',121)      
       then    
                  dbo.fn_hora_HHMMSS_NFE ( DATEADD(hour, -1, getdate()) )    
               else      
                  ns.hr_nota_saida    
               end)) + case when isnull(v.ic_horario_verao,'N')='N' then '-04:00' else '-03:00' end   as 'dEmiNota',    
    
  case when ns.dt_saida_nota_saida is not null then    
  ltrim( rtrim( dbo.fn_strzero(datepart(yyyy,ns.dt_saida_nota_saida),4) +'-'+    
                dbo.fn_strzero(datepart(mm,ns.dt_saida_nota_saida),2)   +'-'+    
                dbo.fn_strzero(datepart(dd,ns.dt_saida_nota_saida),2)   +'T'+    
                       
                case when isnull(ns.hr_saida_nota_saida,'')=''  then    
                  dbo.fn_hora_HHMMSS_NFE ( DATEADD(hour, -1, getdate()) )    
               else      
                  case when cast(replace(ns.hr_saida_nota_saida,':','') as float) < cast(replace(ns.hr_saida_nota_saida,':','') as float)     
                       and    
                       ns.dt_saida_nota_saida is not null     
                       and    
                       ns.dt_nota_saida = ns.dt_saida_nota_saida    
    
                  then    
                       case when isnull(ns.hr_nota_saida,'')='' or ns.dt_nota_saida<convert(datetime,left(convert(varchar,DATEADD(hour, -1, getdate()),121),10)+' 00:00:00',121)  then    
                        dbo.fn_hora_HHMMSS_NFE ( DATEADD(hour, -1, getdate()) )    
                      else      
                        ns.hr_nota_saida    
                      end    
                  else    
                    ltrim(rtrim(ns.hr_saida_nota_saida))    
                    +    
                    case when len(ltrim(rtrim(ns.hr_saida_nota_saida)))=5 then ':00' else '' end               
                  end    
                      
               end))+case when isnull(v.ic_horario_verao,'N')='N' then '-04:00' else '-03:00' end    
  else    
  ltrim( rtrim( dbo.fn_strzero(datepart(yyyy,convert(datetime,left(convert(varchar,DATEADD(hour, -1, getdate()),121),10)+' 00:00:00',121)),4) +'-'+    
                dbo.fn_strzero(datepart(mm,convert(datetime,left(convert(varchar,DATEADD(hour, -1, getdate()),121),10)+' 00:00:00',121)),2)   +'-'+    
                dbo.fn_strzero(datepart(dd,convert(datetime,left(convert(varchar,DATEADD(hour, -1, getdate()),121),10)+' 00:00:00',121)),2)   +'T'+    
                       
                case when isnull(ns.hr_saida_nota_saida,'')='' then    
                  dbo.fn_hora_HHMMSS_NFE ( DATEADD(hour, -1, getdate()) )    
               else      
                  ns.hr_saida_nota_saida    
               end)) + case when isnull(v.ic_horario_verao,'N')='N' then '-04:00' else '-03:00' end    
    
  end                                                                       as 'dEmiNotaSaida',    
                             
--  ns.dt_nota_saida,    
  case when isnull(ns.hr_nota_saida,'')='' or ns.dt_nota_saida<convert(datetime,left(convert(varchar,DATEADD(hour, -1, getdate()),121),10)+' 00:00:00',121)  then    
    dbo.fn_hora_HHMMSS_NFE ( DATEADD(hour, -1, getdate()) )    
  else      
    ns.hr_nota_saida    
  end                                                                                           as hr_nota_saida,    
    
  ns.dt_saida_nota_saida,    
    
  case when isnull(ns.hr_saida_nota_saida,'')='' or ns.dt_nota_saida<convert(datetime,left(convert(varchar,DATEADD(hour, -1, getdate()),121),10)+' 00:00:00',121)  then    
   dbo.fn_hora_HHMMSS_NFE ( DATEADD(hour, -1, getdate()) )     
  else    
    ns.hr_saida_nota_saida    
  end                                                                                          as hr_saida_nota_saida,    
    
--FormatDateTime('YYYY-MM-DD"T"HH:MM:SS',Now)    
    
      
  --Hora Saída/Entrada da Mercadoria    
  --Verificar como podemos gravar e cadastrar o horário correto no sistema    
  --14.08.2010    
    
  case when ns.hr_nota_saida is null    
  then '' -- 07/11/2011 - Marcelo - then '00:00:00'    
  else    
    ns.hr_nota_saida    
  end                                                                                           as 'hSaiEnt',    
    
    
  case when isnull(ns.cd_tipo_operacao_fiscal,0)=2 then '1' else '0' end                        as 'tpNF',    
  ltrim(rtrim(cast(isnull(cid.cd_cidade_ibge,0) as varchar(10))))                               as 'cMunFG',    
     
 --Nota Fiscal Referenciada    
    
  '1'                                                                                           as 'NFref',    
    
  case when isnull(nfr.cd_nota_referencia,0)>0 and    
            isnull(vwr.chaveAcesso,'')<>''    
  then    
    --substring(isnull(vwr.chaveAcesso,''),4,len(isnull(vwr.chaveacesso,'')))                     
    substring(isnull(nsr.cd_chave_acesso,''),4,len(isnull(nsr.cd_chave_acesso,'')))                     
  else    
    ''    
  end                                                                                           as 'refNFe',    
    
  --Dados da Nota Fiscal referenciada    
  --select * from nota_saida_referenciada    
    
  --Complemento para lay-out 2.0---------------------------------------------------------------------------------------    
    
  CAST(vwr.cUF  as char(2))              as B15_cUF,    
  cast(vwr.AAMM as varchar(4))           as B16_AAMM,    
  cast(vwr.CNPJ as varchar(14))          as B17_CNPJ,   --CNPJ    
  cast(vwr.mod  as varchar(2))           as B18_MOD,    --MODELO    
  cast(vwr.serie as varchar(3))          as B19_SERIE,  --SERIE    
  --vwr.cd_nota_saida                      as B20_nNF,    
  --(select xns.cd_identificacao_nota_saida from nota_saida xns where xns.cd_nota_saida = vwr.cd_nota_saida) as B20_nNF,    
  isnull(nfr.cd_nota_referencia,0)as B20_nNF,    
  --antes Carlos --> 23.06.2010    
  --'' as 'refNFe',    
    
  ''                                                                                            as 'RefNF',    
     
  cast('' as varchar(14))                                                                       as 'CNPJ',    
  'AAMM' as 'AAMM',      
      
--  ns.cd_nota_saida                                                                           as 'nNf',      
    
  ltrim(rtrim(cast(( select top 1 cd_formato_danfe_nfe from Versao_NFE with (nolock)    
    where isnull(ic_ativa_versao_nfe,'N') = 'S' ) as varchar(1))))                              as 'tpImp',    
    
  ltrim(rtrim(cast(( select top 1 cd_forma_emissao_nfe   from Versao_NFE with (nolock)    
    where isnull(ic_ativa_versao_nfe,'N') = 'S' ) as varchar(1))))                              as 'tpEmis',    
      
  (select top 1 cDV    
   from vw_nfe_chave_acesso vw  with (nolock) where vw.cd_nota_saida = ns.cd_nota_saida )       as 'cDV',    
      
  rtrim(ltrim(cast(( select top 1 cd_ambiente_nfe       from Versao_NFE with (nolock)    
    where isnull(ic_ativa_versao_nfe,'N') = 'S' ) as varchar(10))))                             as 'tpAmb',    
      
    
  case when isnull(ns.cd_finalidade_nfe,0)=0 or isnull(ns.cd_finalidade_nfe,0)=1 then    
    ltrim(rtrim(cast(( select top 1 cd_finalidade_nfe       from Versao_NFE with (nolock)    
      where isnull(ic_ativa_versao_nfe,'N') = 'S' ) as varchar(5))))                            
  else    
    ltrim(rtrim(cast(isnull(ns.cd_finalidade_nfe,0) as varchar(5))))                            
    
    
  end                                                                                           as 'finNFE',    
    
   ltrim(rtrim(cast(( select top 1 cd_digito_processo_nfe  from Versao_NFE with (nolock)    
    where isnull(ic_ativa_versao_nfe,'N') = 'S' ) as varchar(8))))                              as 'procEmi',    
    
  ( select top 1 nm_processo_emissao_nfe from Versao_NFE with (nolock)    
    where isnull(ic_ativa_versao_nfe,'N') = 'S' )                                               as 'verProc',    
    
  nfr.cd_nota_referencia,    
    
  --Complemento para lay-out 2.0---------------------------------------------------------------------------------------    
      
  CAST('' as char(2))             as B20b_cUF,    
  cast('' as varchar(4))          as B20C_AAMM,    
  cast('' as varchar(14))         as B20D_CNPJ,   --CNPJ    
  cast('' as varchar(11))         as B20E_CPF,    --CPF    
  cast('' as varchar(14))         as B20F_IE,     --IE    
  cast('' as varchar(2))          as B20F_MOD,    --MODELO    
  cast('000' as varchar(3))       as B20G_SERIE,  --SERIE    
  0                               as B20H_nNF,    
  cast('' as varchar(44))         as B20I_refCTe,    
  0                               as B20J_nrefECF,    
  cast('' as varchar(2))          as B20K_mod,    
  cast('' as varchar(3))          as B201_NECF,    
  cast('' as varchar(6))          as B20m_nCOO,    
    
  --Contingência---------------------------------------------------------------------------------------------------------    
    
  cast('' as varchar(8))                 as B28_dhCont, --Data e Hora de Entrada em Contingência,    
  cast('' as varchar(256))               as B29_xjust,   --Justificativa de entrada em Contingência    
    
  --Versão 3.0-----------------------------------------------------------------------------------------------------------------    
    
  cast(lop.sg_local_operacao as char(1)) as B11a_idDest,    
    
  case when isnull(dp.ic_consumidor_final,'N') = 'N' then    
    '0'    
  else    
    '1'    
  end                                    as B25a_indFinal,    
    
  case when isnull(nec.sg_presenca,'9')<>'' then    
    isnull(nec.sg_presenca,'9')    
  else    
    '9'    
  end                                    as B25b_indPres    
    
    
    
    
    
    
        
from    
  nota_saida ns                            with (nolock)     
  left outer join egisadmin.dbo.empresa e  with (nolock) on e.cd_empresa             = dbo.fn_empresa()     
  left outer join Serie_Nota_Fiscal snf    with (nolock) on snf.cd_serie_nota_fiscal = ns.cd_serie_nota    
  left outer join Empresa_Faturamento ef   with (nolock) on ef.cd_empresa            = snf.cd_empresa_selecao    
  left outer join cnae  c                  with (nolock) on c.cd_cnae                = e.cd_cnae    
  left outer join Pais  p                  with (nolock) on p.cd_pais                = case when isnull(snf.cd_empresa_selecao,0) <>0 then    
                                                                                          ef.cd_pais    
                        else                                                                                            
                        e.cd_pais    
                        end    
  left outer join Estado est               with (nolock) on est.cd_estado            = case when isnull(snf.cd_empresa_selecao,0) <>0 then    
                                                                                          ef.cd_estado    
                        else                                                                                            
                        e.cd_estado    
                        end    
  left outer join Cidade cid               with (nolock) on cid.cd_estado            = case when isnull(snf.cd_empresa_selecao,0) <>0 then    
                                                                                          ef.cd_estado    
                        else                                                                                            
                        e.cd_estado    
                        end and    
                                                            cid.cd_cidade            = case when isnull(snf.cd_empresa_selecao,0) <>0 then    
                       ef.cd_cidade    
                        else                                                                                            
                        e.cd_cidade    
                        end    
    
  left outer join Condicao_Pagamento cp         with (nolock) on cp.cd_condicao_pagamento        = ns.cd_condicao_pagamento    
  left outer join Forma_Condicao_Pagamento fcp  with (nolock) on fcp.cd_forma_condicao           = cp.cd_forma_condicao    
  left outer join Indicador_Forma_Pagamento ifp with (nolock) on ifp.cd_indicador                = cp.cd_indicador    
    
    
  left outer join Nota_Saida_Referenciada nfr  with (nolock) on nfr.cd_nota_saida               = ns.cd_nota_saida and    
                                                                nfr.cd_serie_nota               = ns.cd_serie_nota    
  left outer join nota_saida nsr               with (nolock) on nsr.cd_identificacao_nota_saida = nfr.cd_nota_referencia   and    
                                                                nsr.cd_serie_nota               = nfr.cd_serie_nota_origem     
    
  left outer join vw_nfe_chave_acesso     vwr  with (nolock) on vwr.cd_identificacao_nota_saida = nfr.cd_nota_referencia   and    
                                                                vwr.cd_serie_nota               = nfr.cd_serie_nota_origem    
    
  left outer join operacao_fiscal opf          with (nolock) on opf.cd_operacao_fiscal          = ns.cd_operacao_fiscal    
  left outer join grupo_operacao_fiscal gof    with (nolock) on gof.cd_grupo_operacao_fiscal    = opf.cd_grupo_operacao_fiscal     
  left outer join local_operacao lop           with (nolock) on lop.cd_local_operacao           = gof.cd_local_operacao    
  left outer join destinacao_produto dp        with (nolock) on dp.cd_destinacao_produto        = ns.cd_destinacao_produto    
  left outer join NFe_Presenca_comprador nec   with (nolock) on nec.cd_presenca                 = case when opf.cd_presenca >0 then opf.cd_presenca else dp.cd_presenca end  
  left outer join Versao_NFe v                 with (nolock) on v.cd_empresa                    = e.cd_empresa and isnull(v.ic_ativa_versao_nfe,'N')='S'    
  left outer join parametro_faturamento pf     with (nolock) on pf.cd_empresa                   = e.cd_empresa
 
go

--select * from vw_nfe_chave_acesso

--select cd_tipo_operacao_fiscal,* from nota_saida

--select top 1000 * from vw_nfe_chave_acesso

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 10 * from vw_nfe_identificacao_nota_fiscal where cd_identificacao_nota_saida = 3241
--09519352

------------------------------------------------------------------------------------

go