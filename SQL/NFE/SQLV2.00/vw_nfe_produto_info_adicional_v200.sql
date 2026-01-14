IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_produto_info_adicional' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_produto_info_adicional

GO

CREATE VIEW vw_nfe_produto_info_adicional        
------------------------------------------------------------------------------------
--sp_helptext vw_nfe_produto_info_adicional
 -----------------------------------------------------------------------------------
--GBS - Global Business Solution                                                2004
------------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000        
--Autor(es)             : Carlos Cardoso Fernandes        
--Banco de Dados : EGISSQL         
--        
--Objetivo         : Identificação do Detalhe Produto/Serviço da Nota Fiscal         
--                        Dados Adicionais do Produto        
--        
--Data                  : 05.11.2008        
--Atualização           : 23.11.2008 - Ajustes Diversos - Carlos Fernandes        
-- 29.11.2008 - Dados do IPI - Carlos Fernandes        
-- 11.08.2009 - Ajustes Diversos - Carlos Fernandes        
-- 09.09.2009 - Desenvolvimento - Carlos Fernandes        
-- 27.09.2010 - Ajuste para novo lay-out v2.00 - Carlos Fernandes        
-- 30.08.2016 - ICMS desoneração / Zona Franca - Carlos Fernandes        
-- 15.02.2017 - Código EAN - Carlos Fernandes        
-- 27.01.2018 - implantação NFe 4.00 - Fagner/Carlos         
-- 23.07.2018 - código de barra cean - Fagner        
-- 02.10.2018 - FCI - Fagner/Alpha/Carlos        
-- 30.10.2018 - campo do IPI da devolução - Fagner        
-- 07.11.2018 - Base de PIS/COFINS quando for importação - será tratado no delphi        
--              na geração da nfe....(fagner/carlos)        
-- 06.12.2018 - Acerto do campo pICMSInter, Dava problema quando era para não Contribuinte        
--              Fora e dentro do estado - Fagner Cardoso        
-- 13.04.2019 - DIFAL - Carlos e Fagner         
-- 29.04.2019 - Ajuste do Calculo DIFAL e pICMSInterPart - Fagner Cardoso        
-- 14.08.2019 - Acertos dos Campos de IPI- Devolução - Apenas para Simples Nacional - Fagner Cardoso      
-- 14.02.2020 - Cálculo DIFAL para Diversos Estados - Fagner Cardoso      
-- 15.09.2020 - Acerto do campo sg_estado_nota, quando operação presencial -- Fagner Cardoso      
-- 12.04.2021 - Acerto dos campos ST de FCP - Pedro Jardim     
-- 28.06.2022 - Acrescentado campo InfAdProd -- Fagner Cardoso
-- 15.09.2022 - Add campo xProdComplemento para contanecação via SFT - Pedro Jardim 
-- 16.09.2022 - Add campo nm_obs_dev_nota_item - Pedro Jardim
-- 21.09.2022 - Ajuste do campo complemento na descrição do item - Pedro Jardim
-- 02.03.2023 - Inclusão Codigo do Produto Descrição -- Fagner Cardoso
-- 09.11.2023 - Add novo campo Código Beneficio Fiscal da CST - Pedro Jardim / Fagner Cardoso
----------------------------------------------------------------------------------------------------------------        
as        

select        
  ns.cd_identificacao_nota_saida,        
  ns.cd_nota_saida,          
  ns.dt_nota_saida,        
  nsi.cd_item_nota_saida,        
        
   --Descrição Técnica do Produto        
        
   --case when isnull(p.ic_descritivo_nf_produto,'N') = 'S' then        
        
   case when ltrim(rtrim(cast(nsi.ds_item_nota_saida as varchar(500))))<>''         
   then        
     ltrim(rtrim(cast(nsi.ds_item_nota_saida as varchar(250))))        
   else        
     case when isnull(p.ic_descritivo_nf_produto,'N') = 'S' then        
         ltrim(rtrim(cast(p.ds_produto as varchar(250))))        
     else        
        ltrim(ltrim(cast('' as varchar(250))))        
     end        
--    else        
--       cast('' as varchar(250))        
   end        
        
   +        
        
   case when isnull(vnfe.ic_codigo_rev_infoprod,'N')='S' then        
     'ITEM: '+ltrim(rtrim(p.cd_mascara_produto))+'-'+ltrim(rtrim(isnull(p.cd_rev_desenho_produto,'')))        
        
   else        
    cast('' as varchar)        
   end                                                                 as 'infAdProd',        
        
   --Descrição Técnica do Produto        
        
   --case when isnull(p.ic_descritivo_nf_produto,'N') = 'S' then        
   case when substring(ltrim(rtrim(cast(nsi.ds_item_nota_saida as varchar(500)))),251,250)<>''         
   then        
     substring(ltrim(rtrim(cast(nsi.ds_item_nota_saida as varchar(500)))),251,250)        
   else        
     case when isnull(p.ic_descritivo_nf_produto,'N') = 'S' then        
         substring(ltrim(rtrim(cast(p.ds_produto as varchar(500)))),251,250)        
     else        
        ltrim(rtrim(cast('' as varchar(250))))        
     end        
--    else        
--       cast('' as varchar(500))        
   end                               as 'infAdProdc',  

   --produto_cliente
   case when isnull(pc.ic_inf_ad_prod,'N') = 'S' and isnull(pc.nm_inf_ad_prod,'') <> '' then
      CAST( '"' + isnull(pc.nm_inf_ad_prod,'') + '"' as varchar)
   else
      cast('' as varchar)
   end                                                                    as 'infAdProdCod',  

--    --produto_cliente
--    case when isnull(pc.ic_inf_ad_prod,'N') = 'S' and isnull(pc.nm_inf_ad_prod,'') <> '' then
--       CAST( '"' + isnull(pc.nm_inf_ad_prod,'') + '"' as varchar)
--    else
--       cast('' as varchar)
--    end                                   as 'infAdProdCli',
        
  --isnull(nsi.vl_pis,0)+isnull(nsi.vl_cofins,0) as vTotTribItem,        
        
  case when isnull(opf.ic_importacao_op_fiscal,'N')='N' then 0.00 else           
  case when ((isnull(nsi.vl_pis,0)+isnull(nsi.vl_cofins,0)) > 0 and (isnull(nsi.vl_pis,0)+isnull(nsi.vl_cofins,0)) < 1)
    then 1
    else isnull(nsi.vl_pis,0)+isnull(nsi.vl_cofins,0)
  end end                                               as 'nTotTribItem',
        
  dbo.fn_mascara_valor_duas_casas(case when isnull(opf.ic_importacao_op_fiscal,'N')='N' then 0.00 else         
  --isnull(nsi.vl_pis,0)+isnull(nsi.vl_cofins,0) 
  0.00 end)                                               as 'vTotTribItem',        
        
  replace(isnull(cf.cd_cest_classificacao,''),'.','')      as cd_cest_classificacao,        
        
  --Combustível---------------------------------------------------------------------------------------------------------------        
  isnull(opf.ic_combustive_op_fiscal,'N')    as ic_combustivel_op_fiscal,        
  isnull(cf.cd_anp_classificacao,'')         as cProdANP,    
  isnull('GLP','') as descANP,
  dbo.fn_mascara_valor_duas_casas(isnull(60.00,0.00))  as pGLP,
  dbo.fn_mascara_valor_duas_casas(isnull(40.00,0.00))  as pGNn,    
  dbo.fn_mascara_valor_duas_casas(isnull(nsi.vl_unitario_item_nota,0.00))  as vPart,
  --UFCONS        
  --ns.sg_estado_nota_saida                      as UFCONS,     
  case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end as UFCONS,    
  isnull(opf.ic_contribicms_op_fiscal,'S')     as NCICMS,        
--   0.00 as vBCUFDest,        
--   0.00 as pFCPUFDest,        
--   0.00 as pICMSUFDest,        
--   0.00 as pICMSInter,        
--   0.00 as pICMSInterPart,        
--   0.00 as vFCPUFDest,        
--   0.00 as vICMSUFDest,        
--   0.00 as vICMSUFRemet      
        
  dbo.fn_mascara_valor_duas_casas(isnull(nsi.vl_base_difal,0))  as 'vBCUFDest',   
    
  --case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado and       
  --                                                            case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end in ('PA') then        
  --  dbo.fn_mascara_valor_duas_casas(      
  --    case when isnull(cf.ic_base_reduzida,'N') = 'S' then (((nsi.vl_total_item + nsi.vl_ipi)*(ep.pc_difal_estado/100))/(1-(ep.pc_aliquota_icms_interna/100)))      
  --    else ((((nsi.vl_total_item + nsi.vl_ipi - nsi.vl_icms_item) / (1-(ep.pc_aliquota_icms_interna/100))))) end)      
  --else       
          
  --  case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado and       
  --                                                             case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end in ('BA','GO','MG','PR','RS') then      
  --    dbo.fn_mascara_valor_duas_casas((nsi.vl_total_item + nsi.vl_ipi)/(1-(ep.pc_aliquota_icms_interna/100)))      
  --  else      
      
  --    case when isnull(opf.ic_contribicms_op_fiscal,'S')='N' and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado then        
  --      dbo.fn_mascara_valor_duas_casas(case when isnull(emp.ic_simples_empresa,'N')='S' then nsi.vl_total_item else isnull(nsi.vl_base_icms_item,0) end)        
  --    else        
      
  --      ''        
  --    end      
  --  end         
  --end                                                                                                        
         
         
 -- case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado and       
 --                                                             case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end in ('PA') then        
 --      dbo.fn_mascara_valor_duas_casas(      
 --     case when isnull(cf.ic_base_reduzida,'N') = 'S' then (((nsi.vl_total_item + nsi.vl_ipi)*(ep.pc_difal_estado/100))/(1-(ep.pc_aliquota_icms_interna/100)))      
 --else ((((nsi.vl_total_item + nsi.vl_ipi - nsi.vl_icms_item) / (1-(ep.pc_aliquota_icms_interna/100))))) end)      
 -- else       
          
 --   case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado and       
 --                                                              case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end in ('BA','GO','MG','PR','RS') then      
 --     dbo.fn_mascara_valor_duas_casas((nsi.vl_total_item + nsi.vl_ipi)/(1-(ep.pc_aliquota_icms_interna/100)))      
 --   else      
      
 --     case when isnull(opf.ic_contribicms_op_fiscal,'S')='N' and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado then        
 --       dbo.fn_mascara_valor_duas_casas(case when isnull(emp.ic_simples_empresa,'N')='S' then nsi.vl_total_item else isnull(nsi.vl_base_icms_item,0) end)        
 --     else        
      
 --       ''        
 --     end      
 --   end         
 -- end
  dbo.fn_mascara_valor_duas_casas(isnull(nsi.vl_base_difal,0))                                                                                                      as 'vBCFCPUFDest',      
      
      
      
  case when isnull(opf.ic_contribicms_op_fiscal,'S')='N' and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end in ( 'SP','RJ') and       
                                                             case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado then        
    dbo.fn_mascara_valor_duas_casas(isnull(picm.pc_fundo_probreza,0))         
  else        
    '0.00'        
  end                                                                                                    as 'pFCPUFDest',        
        
  case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado then        
    dbo.fn_mascara_valor_duas_casas(isnull(ep.pc_aliquota_icms_interna,0))         
  else        
    ''        
  end                                                                                                    as 'pICMSUFDest',        
       
       
   case when isnull(opf.ic_contribicms_op_fiscal,'S')='N' and isnull(nsi.pc_icms,0)>0 and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado then        
     dbo.fn_mascara_valor_duas_casas(isnull(nsi.pc_icms,0))         
   else        
      case when isnull(opf.ic_contribicms_op_fiscal,'S')='N' and isnull(nsi.pc_icms,0)=0 and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado then        
         case when nsi.cd_procedencia_produto = 1  then        
          dbo.fn_mascara_valor_duas_casas(isnull(ep.pc_aliquota_icms_estado,0))         
         else        
          dbo.fn_mascara_valor_duas_casas(isnull(ep.pc_importado_icms_estado,0))         
        end        
     else        
          ''        
      end        
   end             
                                                                                                 as 'pICMSInter',        
        
      
  case when isnull(opf.ic_contribicms_op_fiscal,'S')='N' and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado then          
    dbo.fn_mascara_valor_duas_casas( isnull(picm.pc_destino,0))           
  else          
   ''          
  end                                                                                                    as 'pICMSInterPart',         
        
        
        
  --case when isnull(opf.ic_contribicms_op_fiscal,'S')='N' and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end in ( 'SP','RJ') and       
  --                                                           case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado then        
  --  dbo.fn_mascara_valor_duas_casas(round(isnull(picm.pc_fundo_probreza,0) / 100 *         
  --  --isnull(nsi.vl_base_icms_item,0) ,2 ))         
  --  case when isnull(emp.ic_simples_empresa,'N')='S' then nsi.vl_total_item else isnull(nsi.vl_base_icms_item,0) end,2))        
  --else        
  --  '0.00'        
  --end
  dbo.fn_mascara_valor_duas_casas(isnull(nsi.vFCP,0))                                                                                                    as 'vFCPUFDest',        
        
  --case when isnull(opf.ic_contribicms_op_fiscal,'S')='N' and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end in ( 'SP','RJ') and       
  --                                                           case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado then          
  --  (round(isnull(picm.pc_fundo_probreza,0) / 100 *         
  --  --isnull(nsi.vl_base_icms_item,0) ,2 ))         
  --  case when isnull(emp.ic_simples_empresa,'N')='S' then nsi.vl_total_item else isnull(nsi.vl_base_icms_item,0) end,2))        
  --else        
  --  ''        
  --end
  isnull(nsi.vFCP,0)                                                                                                    as 'nFCPUFDest',        
        
        
        
--   case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado and       
--                                                               case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end in ('BA','GO','MG','PR','RS') then        
--       dbo.fn_mascara_valor_duas_casas( (((nsi.vl_total_item + nsi.vl_ipi)/(1- ep.pc_aliquota_icms_interna/100)*(ep.pc_aliquota_icms_interna/100))-        
--                                         ((nsi.vl_total_item + nsi.vl_ipi)/(1- ep.pc_aliquota_icms_interna/100)*(ep.pc_aliquota_icms_estado/100))))      
--   else        
--    case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado and       
--                                                                case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end in ('RJ') then      
--       dbo.fn_mascara_valor_duas_casas( (((nsi.vl_total_item + nsi.vl_ipi))*(((ep.pc_aliquota_icms_interna - ep.pc_aliquota_icms_estado))/100)))      
--    else       
--       
--    case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado and       
--                                                                case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end in ('PA') then        
--       dbo.fn_mascara_valor_duas_casas(      
--        case when isnull(cf.ic_base_reduzida,'N') = 'S' then (((nsi.vl_total_item + nsi.vl_ipi)*(ep.pc_difal_estado/100))/(1-(ep.pc_aliquota_icms_interna/100)))*(0.1)      
--     else ((((nsi.vl_total_item + nsi.vl_ipi - nsi.vl_icms_item) / (1-(ep.pc_aliquota_icms_interna/100)))*(ep.pc_aliquota_icms_interna/100))-nsi.vl_icms_item) end)      
--    else       
--     case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado then        
--       dbo.fn_mascara_valor_duas_casas( ((isnull(ep.pc_aliquota_icms_interna,0) - isnull(nsi.pc_icms,0))/100) * isnull(nsi.vl_base_icms_item,0) * picm.pc_destino/100  )         
--     else        
--      ''        
--     end       
--     end       
--     end          
--   end                                                                                                
  dbo.fn_mascara_valor_duas_casas(isnull(nsi.vl_difal,0)) as 'vICMSUFDest',         
      
        
--   case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado and       
--                                                               case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end in ('BA','GO','MG','PR','RS') then        
--                     (((nsi.vl_total_item + nsi.vl_ipi)/(1- ep.pc_aliquota_icms_interna/100)*(ep.pc_aliquota_icms_interna/100))-        
--                      ((nsi.vl_total_item + nsi.vl_ipi)/(1- ep.pc_aliquota_icms_interna/100)*(ep.pc_aliquota_icms_estado/100)))      
--   else        
--    case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado and       
--        case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end in ('RJ') then        
--       ( ((nsi.vl_total_item + nsi.vl_ipi))*(((ep.pc_aliquota_icms_interna - ep.pc_aliquota_icms_estado))/100))        
--    else --fagner        
--       
--       case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado and       
--                                                                case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end in ('PA') then        
--        case when isnull(cf.ic_base_reduzida,'N') = 'S' then (((nsi.vl_total_item + nsi.vl_ipi)*(ep.pc_difal_estado/100))/(1-(ep.pc_aliquota_icms_interna/100)))*(0.1)      
--     else ((((nsi.vl_total_item + nsi.vl_ipi - nsi.vl_icms_item) / (1-(ep.pc_aliquota_icms_interna/100)))*(ep.pc_aliquota_icms_interna/100))-nsi.vl_icms_item) end      
--    else --fagner       
--         
--     case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado then        
--            ( ((isnull(ep.pc_aliquota_icms_interna,0) - isnull(nsi.pc_icms,0))/100) * isnull(nsi.vl_base_icms_item,0) * picm.pc_destino/100  )         
--     else        
--      ''        
--     end          
--     end         
--     end        
--   end                                                                                                    as 'nICMSUFDest',       
  isnull(nsi.vl_difal,0)                                                                                    as 'nICMSUFDest',               
        
  case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado then        
    dbo.fn_mascara_valor_duas_casas( ((isnull(ep.pc_aliquota_icms_interna,0) - isnull(nsi.pc_icms,0))/100) * isnull(nsi.vl_base_icms_item,0) * picm.pc_origem/100  )         
  else        
    ''        
  end                                                                                                    as 'vICMSUFRemet',        
        
  case when isnull(opf.ic_contribicms_op_fiscal,'S')='N'  and case when isnull(opf.cd_presenca,7)= 2 then ns.sg_estado_entrega else ns.sg_estado_nota_saida end <> ee.sg_estado then        
    ( ((isnull(ep.pc_aliquota_icms_interna,0) - isnull(nsi.pc_icms,0))/100) * isnull(nsi.vl_base_icms_item,0) * picm.pc_origem/100  )         
  else        
    ''        
  end                                                                                                    as 'nICMSUFRemet',        
        
  ns.sg_estado_nota_saida,        
        
        
  case when isnull(nsi.vl_icms_desoneracao,0)<>0 then        
    dbo.fn_mascara_valor_duas_casas( isnull(nsi.vl_icms_desoneracao,0) )         
  else        
    ''        
  end                             as 'vICMSDeson',        
        
          
  case when isnull(nsi.vl_icms_desoneracao,0)<>0 then        
    dbo.fn_strzero(isnull(cd_nfe_desoneracao,7),1)        
  else        
    ''        
  end                                                                                                    as 'motDesICMS',        
        
        
  --Código de Barra---              
  case when isnull(emp.ic_medida_comercial,'N') = 'S' then  
    case when isnull(mc.ic_etiqueta_grande,'N') = 'S' then  
      case when isnull(mc.ic_dun_grande,'N') = 'S' and isnull(mc.cd_dun14_cliente_grande,'') <> '' then  
        isnull(mc.cd_dun14_cliente_grande,'SEM GTIN')  
      else  
        case when isnull(mc.ic_ean_grande,'N') = 'S' and isnull(mc.cd_ean13_cliente_grande,'') <> '' then  
          isnull(mc.cd_ean13_cliente_grande,'SEM GTIN')  
        else  
          case when isnull(nsi.cd_codigo_barra_produto,'')<>'' then              
            nsi.cd_codigo_barra_produto              
          else              
            case when isnull(p.cd_codigo_barra_produto,'')<>'' then              
              cast(p.cd_codigo_barra_produto as varchar(14))              
            else              
              cast('SEM GTIN' as varchar(14))                                                                    
            end              
          end  
        end  
      end  
    else  
      case when isnull(mc.ic_dun,'N') = 'S' and isnull(mc.cd_dun14_cliente,'') <> '' then  
        isnull(mc.cd_dun14_cliente,'SEM GTIN')  
      else  
        case when isnull(mc.ic_ean,'N') = 'S' and isnull(mc.cd_ean13_cliente,'') <> '' then  
          isnull(mc.cd_ean13_cliente,'SEM GTIN')  
        else  
          case when isnull(nsi.cd_codigo_barra_produto,'')<>'' then              
            nsi.cd_codigo_barra_produto              
          else              
            case when isnull(p.cd_codigo_barra_produto,'')<>'' then              
              cast(p.cd_codigo_barra_produto as varchar(14))              
            else              
              cast('SEM GTIN' as varchar(14))                                                                    
            end              
          end  
        end  
      end  
    end  
  else  
    case when isnull(efat.cd_empresa,0) = 0
    then 
      case when isnull(nsi.cd_codigo_barra_produto,'')<>'' then              
        nsi.cd_codigo_barra_produto              
      else              
        case when isnull(p.cd_codigo_barra_produto,'')<>'' then              
          cast(p.cd_codigo_barra_produto as varchar(14))              
        else              
          cast('SEM GTIN' as varchar(14))                                                                    
        end              
      end
    else
      case when isnull(efat.ic_gtin_empresa,'N') = 'S'      
      then              
        case when (isnull(cg.ic_tipo_ean_dun,'1') = '2') and (rtrim(ltrim(cast(um.sg_unidade_medida as varchar(6)))) = 'CX')      
          then case when (isnull(p.cd_dun_barra_produto,'')<>'') and (isnull(pf.ic_gtin_nfe_produto,'N') = 'S')       
                 then cast(p.cd_dun_barra_produto as varchar(14))                  
                 else case when (isnull(p.cd_codigo_barra_produto,'')<>'') and (isnull(pf.ic_gtin_nfe_produto,'N') = 'S')      
                        then cast(p.cd_codigo_barra_produto as varchar(14))                  
                        else cast('SEM GTIN' as   varchar(14))                                                                        
                      end      
               end      
          else       
            
               case when (isnull(p.cd_codigo_barra_produto,'')<>'') and (isnull(pf.ic_gtin_nfe_produto,'N') = 'S')      
                 then cast(p.cd_codigo_barra_produto as varchar(14))                  
                 else cast('SEM GTIN' as   varchar(14))                                                                        
               end      
            
        end                                                                                                       
      else      
        cast('SEM GTIN' as   varchar(14))      
      end
    end  
  end                                                                                                as 'cEan',              
              
  case when isnull(emp.ic_medida_comercial,'N') = 'S' then  
    case when isnull(mc.ic_etiqueta_grande,'N') = 'S' then  
      case when isnull(mc.ic_dun_grande,'N') = 'S' and isnull(mc.cd_dun14_cliente_grande,'') <> '' then  
        isnull(mc.cd_dun14_cliente_grande,'SEM GTIN')  
      else  
        case when isnull(mc.ic_ean_grande,'N') = 'S' and isnull(mc.cd_ean13_cliente_grande,'') <> '' then  
          isnull(mc.cd_ean13_cliente_grande,'SEM GTIN')  
        else  
          case when isnull(nsi.cd_codigo_barra_produto,'')<>'' then              
            nsi.cd_codigo_barra_produto              
          else              
            case when isnull(p.cd_codigo_barra_produto,'')<>'' then              
              cast(p.cd_codigo_barra_produto as varchar(14))              
            else              
              cast('SEM GTIN' as varchar(14))                                                                    
            end              
          end  
        end  
      end  
    else  
      case when isnull(mc.ic_dun,'N') = 'S' and isnull(mc.cd_dun14_cliente,'') <> '' then  
        isnull(mc.cd_dun14_cliente,'SEM GTIN')  
      else  
        case when isnull(mc.ic_ean,'N') = 'S' and isnull(mc.cd_ean13_cliente,'') <> '' then  
          isnull(mc.cd_ean13_cliente,'SEM GTIN')  
        else  
          case when isnull(nsi.cd_codigo_barra_produto,'')<>'' then              
            nsi.cd_codigo_barra_produto              
          else              
            case when isnull(p.cd_codigo_barra_produto,'')<>'' then              
              cast(p.cd_codigo_barra_produto as varchar(14))              
            else              
              cast('SEM GTIN' as varchar(14))                                                                    
            end              
          end  
        end  
      end  
    end  
  else  
    case when isnull(efat.cd_empresa,0) = 0
    then 
      case when isnull(nsi.cd_codigo_barra_produto,'')<>'' then              
        nsi.cd_codigo_barra_produto              
      else              
        case when isnull(p.cd_codigo_barra_produto,'')<>'' then              
          cast(p.cd_codigo_barra_produto as varchar(14))              
        else              
          cast('SEM GTIN' as varchar(14))                                                                    
        end              
      end
    else
      case when isnull(efat.ic_gtin_empresa,'N') = 'S'      
      then              
        case when (isnull(cg.ic_tipo_ean_dun,'1') = '2') and (rtrim(ltrim(cast(um.sg_unidade_medida as varchar(6)))) = 'CX')      
          then case when (isnull(p.cd_dun_barra_produto,'')<>'') and (isnull(pf.ic_gtin_nfe_produto,'N') = 'S')       
                 then cast(p.cd_dun_barra_produto as varchar(14))                  
                 else case when (isnull(p.cd_codigo_barra_produto,'')<>'') and (isnull(pf.ic_gtin_nfe_produto,'N') = 'S')      
                        then cast(p.cd_codigo_barra_produto as varchar(14))                  
                        else cast('SEM GTIN' as   varchar(14))                                                                        
                      end      
               end      
          else       
            
               case when (isnull(p.cd_codigo_barra_produto,'')<>'') and (isnull(pf.ic_gtin_nfe_produto,'N') = 'S')      
                 then cast(p.cd_codigo_barra_produto as varchar(14))                  
                 else cast('SEM GTIN' as   varchar(14))                                                                        
               end      
            
        end                                                                                                       
      else      
        cast('SEM GTIN' as   varchar(14))      
      end
    end 
  end                                                                                                  as 'cEanTrib',       
        
  dbo.fn_mascara_valor_duas_casas( cast(nsi.vBCFCP as decimal(25,2)) )                                 as 'vBCFCP',        
  dbo.fn_mascara_valor_duas_casas( cast(nsi.pFCP as decimal(25,2)) )                                   as 'pFCP',        
  dbo.fn_mascara_valor_duas_casas( cast(nsi.VFCP as decimal(25,2)) )                                   as 'vFCP',        
      
--  dbo.fn_mascara_valor_duas_casas( cast(0.00 as decimal(25,2)) )                                   as 'vBCFCPST',        
          
  case when ti.cd_digito_tributacao_icms = '60' and isnull(dp.ic_consumidor_final,'N') = 'S' and isnull(nsi.vl_bc_subst_icms_item,0) > 0 then        
     dbo.fn_mascara_valor_duas_casas( cast(nsi.pFCP as decimal(25,2)) )         
  else         
     case when ti.cd_digito_tributacao_icms = '60' and isnull(nsi.pFCP,0)=0  then         
       dbo.fn_mascara_valor_duas_casas( cast(isnull(ep.pc_aliquota_icms_interna,0) as decimal(25,2)) )           
     else case when isnull(nsi.vl_bc_subst_icms_item,0) > 0 then      
            dbo.fn_mascara_valor_duas_casas( cast(nsi.pFCP as decimal(25,2)) )        
          else      
            dbo.fn_mascara_valor_duas_casas( cast(0.00 as decimal(25,2)) )      
          end      
     end        
  end                                                                                                 as 'pFCPST',        
        
        
        
  case when ti.cd_digito_tributacao_icms = '60' and isnull(dp.ic_consumidor_final,'N') = 'S' then        
     dbo.fn_mascara_valor_duas_casas( cast(0.00 as decimal(25,2)) )         
  else        
     case when ti.cd_digito_tributacao_icms = '60'   then         
     dbo.fn_mascara_valor_duas_casas( cast(isnull((isnull(nsi.vl_total_item,0) +        
                                           isnull(nsi.vl_ipi,0)        +         
                isnull(nsi.vl_frete_item,0))*        
       (isnull(ep.pc_aliquota_icms_interna,0)/100),0) as decimal(25,2)) )        
  else        
     dbo.fn_mascara_valor_duas_casas( cast(0.00 as decimal(25,2)) )        
     end        
  end                                                                                             as 'vICMSSubstituto',        
  case when isnull(nsi.vl_bc_subst_icms_item,0) > 0 then      
    dbo.fn_mascara_valor_duas_casas( cast(VFCP as decimal(25,2)) )      
  else       
    dbo.fn_mascara_valor_duas_casas( cast(0.00 as decimal(25,2)) )      
  end    as 'vFCPST',        
      
        
        
--   cast('' as varchar) as 'pFCP',        
--   cast('' as varchar) as 'vFCP',        
      
   case when isnull(nsi.vl_bc_subst_icms_item,0) > 0 then      
       dbo.fn_mascara_valor_duas_casas( cast(nsi.vBCFCP as decimal(25,2)) )        
   else      
       cast('' as varchar)       
   end                                                                                            as 'vBCFCPST',        
      
--   cast('' as varchar) as 'pFCPST',        
--   cast('' as varchar) as 'vFCPST',        
        
        
  --FCI        
  case when isnull(pp.cd_digito_procedencia,0) in (1,2,3,5,6,7) then
    isnull(nsi.cd_fci,'') 
  else
    ''
  end as cd_fci,        
        
--  Valor IPI de Devolução        
        
  dbo.fn_mascara_valor_duas_casas( cast(case when isnull(ns.cd_finalidade_nfe,0)=4 and isnull(nsi.vl_ipi,0)>0 and case when isnull(efat.cd_empresa,0) = 0 then isnull(emp.ic_simples_empresa,'N') else isnull(efat.ic_simples_empresa,'N') end = 'S'
  then isnull(nsi.vl_ipi,0) else 0.00 end as decimal(25,2)) )        as 'vIPIDevol',        
        
  dbo.fn_mascara_valor_duas_casas( cast(case when isnull(ns.cd_finalidade_nfe,0)=4 and isnull(nsi.vl_ipi,0)>0 and case when isnull(efat.cd_empresa,0) = 0 then isnull(emp.ic_simples_empresa,'N') else isnull(efat.ic_simples_empresa,'N') end = 'S'
  then isnull(100,0) else 0.00 end as decimal(25,2)) )                                    as 'pIPIDevol',        
        
  --base de pis e cofins        
  dbo.fn_mascara_valor_duas_casas( cast(isnull(vl_base_pis_item,0)    as decimal(25,2)) )                                   as 'vBCPIS',        
  dbo.fn_mascara_valor_duas_casas( cast(isnull(vl_base_cofins_item,0) as decimal(25,2)) )                                   as 'vBCCOFINS',       

 --Descrição Técnica do Produto 1
 case when isnull(cp.ic_tec_pedido_nota,'N') = 'S' then
  case when vf.ic_inf_descricao_prod_danfe = 'S'
    then case when ltrim(rtrim(cast(nsi.ds_item_nota_saida as varchar(500))))<>'' --and ((isnull(p.ic_descritivo_nf_produto,'N') = 'S') or (isnull(nsi.cd_produto,0) = 0))
           then case when isnull(cast(nsi.ds_item_nota_saida as varchar(500)),'')<>'' 
                  then cast(nsi.ds_item_nota_saida as varchar(500))
                end  
           else case when isnull(p.ic_descritivo_nf_produto,'N') = 'S' and ltrim(rtrim(cast(p.ds_produto as varchar(500))))<>''
                  then case when isnull(cast(p.ds_produto as varchar(500)),'')<>'' 
                         then cast(p.ds_produto as varchar(500))
                         end
                  else cast(null as varchar(500) )
                end
         end
    else  cast('' as varchar(500) )
  end
    else  cast('' as varchar(500) )
  end     
  +
  --Devolução do item
  case when isnull(opf.cd_operacao_fiscal,0) > 0 and isnull(nsi.nm_obs_dev_nota_item,'') <> '' then 
     isnull(nsi.nm_obs_dev_nota_item,'')
   else
     ''
   end  
  +
  --FCI
  case when isnull(nsi.cd_fci,'') <> '' and isnull(pp.cd_digito_procedencia,0) in (1,2,3,5,6,7) then 
     ' FCI: ' + isnull(nsi.cd_fci,'')
   else
     ''
   end 
   +
     --Código do Produto na Descrição
  case when isnull(cp.ic_imprime_mascara_produto,'N') = 'S' then
    case when isnull(p.cd_mascara_produto,'') <> '' then
       ' ( ' + isnull(p.cd_mascara_produto,'') + ' )'
	else
	   ''
	end
  else
    ''
  end as 'xProdComplemento',
  isnull(ti.cd_benef_fiscal,'') as 'cBenef'
        
from        
  Nota_Saida ns                                       with (nolock)         
  inner join Nota_Saida_Item nsi                      with (nolock) on nsi.cd_nota_saida             = ns.cd_nota_saida        
  left outer join Operacao_Fiscal opf                 with (nolock) on opf.cd_operacao_fiscal        = nsi.cd_operacao_fiscal        
        
  left outer join Produto                       p     with (nolock) on p.cd_produto                  = nsi.cd_produto        
  left outer join Unidade_Medida um                   with (nolock) on um.cd_unidade_medida          = nsi.cd_unidade_medida            
  left outer join versao_nfe vnfe                     with (nolock) on vnfe.cd_empresa               = dbo.fn_empresa()        
  left outer join classificacao_fiscal cf             with (nolock) on cf.cd_classificacao_fiscal    = nsi.cd_classificacao_fiscal        
  left outer join Partilha_ICMS_Nao_Contribuinte picm with (nolock) on picm.cd_ano                   = year(ns.dt_nota_saida)        
  left outer join estado e                            with (nolock) on e.sg_estado                   = ns.sg_estado_nota_saida        
  left outer join estado_parametro ep                 with (nolock) on ep.cd_estado                  = e.cd_estado and        
                                                                       ep.cd_pais                    = e.cd_pais        
  left outer join egisadmin.dbo.empresa emp           with (nolock) on emp.cd_empresa                = dbo.fn_empresa()        
  left outer join estado ee                           with (nolock) on ee.cd_estado                  = emp.cd_estado        
  left outer join motivo_desoneracao md               with (nolock) on md.cd_motivo_desoneracao      = nsi.cd_motivo_desoneracao        
  left outer join tributacao t                        with (nolock) on t.cd_tributacao               = nsi.cd_tributacao        
  left outer join tributacao_icms ti                  with (nolock) on ti.cd_tributacao_icms         = t.cd_tributacao_icms        
  left outer join Destinacao_Produto dp               with (nolock) on dp.cd_destinacao_produto      = ns.cd_destinacao_produto        
  left outer join Produto_Cliente pc                  with (nolock) on pc.cd_produto                 = nsi.cd_produto and
                                                                       pc.cd_cliente                 = ns.cd_cliente
  left outer join Cliente_Parametro cp                with (nolock) on cp.cd_cliente                 = ns.cd_cliente
  left outer join Cliente c                           with (nolock) on c.cd_cliente                  = ns.cd_cliente
  left outer join Cliente_Grupo cg                    with (nolock) on cg.cd_cliente_grupo           = c.cd_cliente_grupo
  left outer join Versao_Nfe vf                       with (nolock) on vf.cd_empresa                 = dbo.fn_empresa()
  left outer join Produto_Fiscal pf                   with (nolock) on pf.cd_produto                 = nsi.cd_produto
  left outer join Serie_Nota_Fiscal snf               with (nolock) on snf.cd_serie_nota_fiscal      = ns.cd_serie_nota            
  left outer join Empresa_Faturamento efat            with (nolock) on efat.cd_empresa               = snf.cd_empresa_selecao
  left outer join Procedencia_Produto pp              with (nolock) on pp.cd_procedencia_produto     = nsi.cd_procedencia_produto
  left outer join Pedido_Venda_Item_Medida_Cliente mc with (nolock) on mc.cd_pedido_venda            = nsi.cd_pedido_venda
                                                                   and mc.cd_item_pedido_venda       = nsi.cd_item_pedido_venda

go

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--select * from vw_nfe_produto_info_adicional where cd_nota_saida = 50089
--select vICMSUFDest, * from vw_nfe_produto_info_adicional where cd_identificacao_nota_saida = 232
------------------------------------------------------------------------------------

go


-- Grupo  ICMSUFDest  - Informação do ICMS Interestadual
-- 
-- Campo	ID	Descrição
-- vBCUFDest	vBCUFDest_NA03	Valor da BC do ICMS na UF de destino
-- pFCPUFDest	pFCPUFDest_NA05	Percentual do ICMS relativo ao Fundo de Combate à Pobreza
-- pICMSUFDest	pICMSUFDest_NA07	Alíquota interna da UF de destino
-- pICMSInter	pICMSInter_NA09	Alíquota interestadual das UF envolvidas 
-- pICMSInterPart	pICMSInterPart_NA11	Percentual provisório de partilha do ICMS Interestadual 
-- vFCPUFDest	vFCPUFDest_NA13	Valor do ICMS relativo ao Fundo de Combate à Pobreza
-- vICMSUFDest	vICMSUFDest_NA15	Valor do ICMS Interestadual para a UF de destino 
-- vICMSUFRemet	vICMSUFRemet_NA17  	Valor do ICMS Interestadual para a UF do remetente