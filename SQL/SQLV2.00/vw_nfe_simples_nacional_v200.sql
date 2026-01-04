IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_simples_nacional_v200' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_simples_nacional_v200

GO

------------------------------------------------------------------------------------     
--sp_helptext vw_nfe_simples_nacional_v200    
 ------------------------------------------------------------------------------------    
--GBS - Global Business Solution                                         2010    
------------------------------------------------------------------------------------    
--Stored Procedure : Microsoft SQL Server 2000    
--Autor(es)             : Carlos Cardoso Fernandes    
--Banco de Dados : EGISSQL     
--    
--Objetivo         : Simples Nacional    
--                            
--    
--Data                  : 27.09.2010     
--Atualização           :     
-- 27.09.2010 - Ajuste para novo lay-out v2.00 - Carlos Fernandes    
-- 05.04.2011 - Finalização do Desenvolvimento - Carlos Fernandes    
-- 30.04.2011 - Ajuste da ST / Base de Cálculo - Carlos /Luis Santana    
-- 10.12.2013 - Nova forma de buscar a CSOSN pela Tributação - Luis/Carlos     
-- 26.07.2021 - Acertos para quando tiver diversas empresas - Carlos Fernandes 
-- 04.06.2024 - Ajuste do Credito do ICMS por Item  - Pedro/Luis   
------------------------------------------------------------------------------------    
    
CREATE VIEW vw_nfe_simples_nacional_v200    
as    
    
--select * from nota_saida_item    
-- select    
--    pfi.*,    
--    i.*    
--        
-- from    
--   Parametro_Faturamento_Imposto pfi    
--   left outer join Imposto_Simples i with (nolock) on i.cd_imposto_simples = pfi.cd_imposto_simples    
-- where    
--   pfi.cd_empresa = dbo.fn_empresa()    
    
    
    
select    
  ns.cd_identificacao_nota_saida,    
  ns.cd_nota_saida,      
  nsi.cd_item_nota_saida,    
  ns.dt_nota_saida,    
--  vw.cd_situacao_operacao,    
    
  rtrim(ltrim(cast(isnull(pp.cd_digito_procedencia,0) as varchar(1))))                                as 'orig',    
    
  cast(so.cd_identificacao_situacao as varchar(03))                                                   as 'CSOSN',    
    
--  isnull(i.pc_icms,0)                                                                                 as 'pCredSN',    
    
  dbo.fn_mascara_valor_duas_casas(case when isnull(ef.pc_icms_simples,0)>0 then  
                                     isnull(ef.pc_icms_simples,0)  
          else  
           isnull(i.pc_icms,0)  
          end)                                                               as 'pCredSN',    
    
   
  dbo.fn_mascara_valor_duas_casas(isnull(nsi.vl_total_item,0) * case when isnull(ef.pc_icms_simples,0)>0 then  
                                                             isnull(ef.pc_icms_simples,0)  
                                  else  
                                   isnull(i.pc_icms,0)  
                                  end/100)                    as 'vCredICMSSN',    
    
  so.cd_situacao_operacao,    
    
  --201 --> Substituição Tributária---------------------------------------------------------------------    
    
--  case when ti.cd_digito_tributacao_icms = '10' then               
     ltrim(rtrim(cast(isnull(mct.cd_digito_modalidade_st,0) as varchar(10))))                                             
--  else              
--     cast('0' as varchar(10))              
--  end    
                                                                                               as 'modBCST',              
              
--   case when ti.cd_digito_tributacao_icms = '10' then               
--     case when isnull(cfe.pc_icms_strib_clas_fiscal,0)>0 then    
--         dbo.fn_mascara_valor_duas_casas(cfe.pc_icms_strib_clas_fiscal)               
--     else    
--         case when nsi.pc_subs_trib_item > 0 then               
--            dbo.fn_mascara_valor_duas_casas(nsi.pc_subs_trib_item)                   
--         else    
--            dbo.fn_mascara_valor_duas_casas(0.00)               
--         end    
--      
--     end    
--     
--   else              
--     dbo.fn_mascara_valor_duas_casas(0.00)               --   end                                                                                               as 'pMVAST',              
--               
--   case when ti.cd_digito_tributacao_icms = '10' and cfe.pc_red_icms_clas_fiscal > 0 then               
--     dbo.fn_mascara_valor_duas_casas(cfe.pc_red_icms_clas_fiscal)               
--   else              
--     dbo.fn_mascara_valor_duas_casas(0.00)               
--   end                                                                                               as 'pRedBCST',              
              
--  case when ti.cd_digito_tributacao_icms = '10' then               
    case when isnull(nsi.pc_subs_trib_item,0) > 0 then               
      dbo.fn_mascara_valor_duas_casas(nsi.pc_subs_trib_item)                   
    else    
     '0.00'    
    end    
     
--  else              
--    dbo.fn_mascara_valor_duas_casas(0.00)               
--  end    
                                                                                               as 'pMVAST',              
    
--  case when ti.cd_digito_tributacao_icms = '10' then               
    case when isnull(nsi.vl_bc_subst_icms_item,0) > 0 then               
      dbo.fn_mascara_valor_duas_casas(round(nsi.vl_bc_subst_icms_item * (nsi.pc_icms_interna_st/100),2))               
    else              
      '0.00'    
    end    
--  else              
--    dbo.fn_mascara_valor_duas_casas(0.00)               
--  end    
                                                                                               as 'pRedBCST',              
    
    
--  case when ti.cd_digito_tributacao_icms = '10' then               
--    dbo.fn_mascara_valor_duas_casas(nsi.vl_bc_subst_icms_item)                   
    dbo.fn_mascara_valor_duas_casas(case when isnull(opf.ic_subst_tributaria,'N')='S' and      
                                    isnull(nsi.vl_bc_subst_icms_item,0)>0     
                                    then vl_bc_subst_icms_item    
                                    else 0.00 end)    
    
--  else              
--    dbo.fn_mascara_valor_duas_casas(0.00)               
--  end    
                                                                                               as 'vBCST',              
    dbo.fn_mascara_valor_duas_casas(case when isnull(opf.ic_subst_tributaria,'N')='S' and      
                                    isnull(nsi.vl_bc_subst_icms_item,0)>0     
                                    then vl_bc_subst_icms_item    
                                    else 0.00 end)    
    
--  else              
--    dbo.fn_mascara_valor_duas_casas(0.00)               
--  end    
                                                                                               as 'vBCSST',              
              
  --% ICMS Interna    
    
  case when isnull(cfe.pc_interna_icms_clas_fis,0)<>0 then    
     dbo.fn_mascara_valor_duas_casas(isnull(cfe.pc_interna_icms_clas_fis,0))                                                
  else            
     dbo.fn_mascara_valor_duas_casas(isnull(nsi.pc_icms,0))                                                 
  end                                                                                                  as 'pICMSST',    
    
--  case when ti.cd_digito_tributacao_icms = '10' then               
--    dbo.fn_mascara_valor_duas_casas(nsi.vl_icms_subst_icms_item)              
    dbo.fn_mascara_valor_duas_casas(case when isnull(opf.ic_subst_tributaria,'N')='S' and      
                                    isnull(nsi.vl_bc_subst_icms_item,0)>0     
                                    then nsi.vl_icms_subst_icms_item    
                                    else 0.00 end)    
    
--  else              
--    dbo.fn_mascara_valor_duas_casas(0.00)               
--  end     
                                                                                              as 'vICMSST',    
    
  case when ti.cd_digito_tributacao_icms = '20' then               
    rtrim(ltrim(cast(ti.cd_digito_tributacao_icms as varchar(2))))                                                
  else              
    cast('20' as varchar(2))              
  end                                                                                               as 'CST20',              
              
  case when ti.cd_digito_tributacao_icms = '20' then               
    rtrim(ltrim(cast(isnull(mci.cd_digito_modalidade,0)  as varchar(1))))                                                
  else              
    cast('0' as varchar(1))              
  end                                                                                               as 'modBC20',              
              
              
  case when ti.cd_digito_tributacao_icms = '20' then               
    dbo.fn_mascara_valor_duas_casas(nsi.pc_reducao_icms)                      
  else              
    dbo.fn_mascara_valor_duas_casas(0.00)                      
  end                                                                                               as 'pREDBC20',              
              
  case when ti.cd_digito_tributacao_icms in ('00','20') then               
    dbo.fn_mascara_valor_duas_casas(nsi.vl_base_icms_item)                     
  else              
    dbo.fn_mascara_valor_duas_casas(0.00)                      
  end           as 'vBC20',              
              
  case when ti.cd_digito_tributacao_icms in ('00','20') then               
    dbo.fn_mascara_valor_duas_casas(nsi.pc_icms)                            
  else              
    dbo.fn_mascara_valor_duas_casas(0.00)                            
  end                                                                                               as 'pICMS20',              
                
  case when ti.cd_digito_tributacao_icms in ('00','20') then               
    dbo.fn_mascara_valor_duas_casas(nsi.vl_icms_item)              
  else              
    dbo.fn_mascara_valor_duas_casas(0.00)              
  end                                                                                               as 'vICMS20',    
    
  dbo.fn_mascara_valor_duas_casas( cast(0.00 as decimal(25,2)) )                                   as 'vBCFCPST',    
  dbo.fn_mascara_valor_duas_casas( cast(0.00 as decimal(25,2)) )                                   as 'pFCPST',    
  dbo.fn_mascara_valor_duas_casas( cast(0.00 as decimal(25,2)) )                                   as 'vFCPST'    
    
    
    
--select vl_total,* from nota_saida    
    
--   modBC,    
--   pRedBC,    
--   vBC,    
--   pICMS,    
--   vICMS,    
--   modBCST,    
--   pMVAST,    
--   pRedBCST,    
--   vBCST,    
--   pICMSST,    
--   vICMSST,    
--   pCredSN,    
--   vCredICMSSN    
    
    
from    
  nota_saida ns                                     with (nolock)     
  inner join nota_saida_item nsi                    with (nolock) on nsi.cd_nota_saida             = ns.cd_nota_saida    
  left outer join operacao_fiscal opf               with (nolock) on opf.cd_operacao_fiscal        = nsi.cd_operacao_fiscal    
  left outer join vw_destinatario vw                with (nolock) on vw.cd_destinatario            = ns.cd_cliente and    
                                                                     vw.cd_tipo_destinatario       = ns.cd_tipo_destinatario    
  left outer join produto                       p   with (nolock) on p.cd_produto                  = nsi.cd_produto    
  left outer join produto_fiscal pf                 with (nolock) on pf.cd_produto                 = nsi.cd_produto    
  left outer join procedencia_produto pp            with (nolock) on pp.cd_procedencia_produto     = nsi.cd_procedencia_produto    
  left outer join tributacao t                      with (nolock) on t.cd_tributacao               = nsi.cd_tributacao    
  left outer join tributacao_icms ti                with (nolock) on ti.cd_tributacao_icms         = t.cd_tributacao_icms    
  left outer join egisadmin.dbo.empresa         e   with (nolock) on e.cd_empresa                  = dbo.fn_empresa()    
    
  left outer join Parametro_Faturamento_Imposto pfi with (nolock) on pfi.cd_empresa                = e.cd_empresa    
    
  left outer join Imposto_Simples i                 with (nolock) on i.cd_imposto_simples          = pfi.cd_imposto_simples    
    
  --Alterado 10.12.2013    
  --Carlos    
  --select * from Situacao_Operacao_Simples    
  left outer join Situacao_Operacao_Simples so      with (nolock) on so.cd_situacao_operacao       = case when isnull(t.cd_situacao_operacao,0)<>0 then    
                                                                                                       t.cd_situacao_operacao    
                                                                                                     else    
                            case when isnull(opf.cd_situacao_operacao,0)>0 then    
                               opf.cd_situacao_operacao    
                                else    
                                                                                                         case when isnull(vw.cd_situacao_operacao,0)<>0 then    
                                                                                                           vw.cd_situacao_operacao    
                                                                                                         else    
                                                                                                           pfi.cd_situacao_operacao    
                                                                                                         end    
                                                                                                       end    
                                                                                                     end    
      
  left outer join modalidade_calculo_icms mci       with (nolock) on mci.cd_modalidade_icms        = t.cd_modalidade_icms    
  left outer join modalidade_calculo_icms_sTrib mct with (nolock) on mct.cd_modalidade_icms_st     = t.cd_modalidade_icms_st    
  left outer join classificacao_fiscal_estado cfe   with (nolock) on cfe.cd_classificacao_fiscal   = nsi.cd_classificacao_fiscal and    
                                                                     cfe.cd_estado                 = vw.cd_estado   
  left outer join Serie_Nota_Fiscal ser             With(Nolock) on ser.cd_serie_nota_fiscal = ns.cd_serie_nota  
  left outer join Empresa_Faturamento ef            With(Nolock) on ef.cd_empresa            = ser.cd_empresa_selecao  
    
go

--select * from imposto_simples

--select * from situacao_operacao_simples

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--select * from vw_nfe_simples_nacional_v200 where cd_identificacao_nota_saida = 616
------------------------------------------------------------------------------------

go