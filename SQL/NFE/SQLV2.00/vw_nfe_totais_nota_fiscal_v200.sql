IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_totais_nota_fiscal' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_totais_nota_fiscal
GO

CREATE VIEW vw_nfe_totais_nota_fiscal
------------------------------------------------------------------------------------
--sp_helptext vw_nfe_totais_nota_fiscal
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2004
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)          : Carlos Cardoso Fernandes
--Banco de Dados	   : EGISSQL 
--
--Objetivo	        : Valores Totais da Nota Fiscal 
--                        para o sistema de emissão da Nota Fiscal Eletrônica
--
--Data                  : 05.11.2008
--Atualização           : 23.02.2010 - Verificação de Totais - Carlos Fernandes 
-- 06.10.2010 - Ajuste para novo lay-out v2.00 - Carlos Fernandes
-- 17.11.2010 - Ajuste do Frete - Carlos / Luis Santana
-- 07.02.2012 - Modificação na sumarização dos totais do produto não aplicar o desconto -  VER NT2011/004 - Marcelo
-- 29.03.2014 - Novos Campos - Carlos Fernandes
-- 06.05.2014 - Campos para Nota Fiscal Eletrônica - 3.0 - Carlos Fernandes
-- 31.08.2016 - Total do ICMS Desoneração - Carlos Fernandes
-- 27.01.2018 - Novos campos do Totais - Carlos Fernandes
-- 03.08.2018 - fagner, ajustou o valor dos produtos - Fagner/Carlos Fernandes
-- 08.11.2018 - Acerto Valor do IPI 0 quando Nota de Devolução - Fagner Cardoso
-- 10.07.2019 - Campos do FCP - Carlos Fernandes
-- 14.08.2019 - Acertos dos Campos de IPI- Devolução - Apenas para Simples Nacional - Fagner Cardoso
-- 12.04.2021 - Ajuste dos valores de FCP com ST - Pedro Jardim
-- 19.04.2021 - Ajuste do DIFAL para o estado do MG - Pedro Jardim
-- 22.04.2021 - Ajuste do DIFAL para o estado do GO - Pedro Jardim
---------------------------------------------------------------------------------------------------------
as

--select * from nota_saida_itemvw_nfe_totais_nota_fiscal
--select * from nota_saida

select
  ns.cd_identificacao_nota_saida,
  ns.dt_nota_saida,
  ns.cd_nota_saida,
  'W'                                                                                                    as 'total',
  'W02'                                                                                                  as 'ICMSTot',--

--  ns.vl_bc_icms                 as 'vBC',--
--   ns.vl_icms                    as 'vICMS',--
--   ns.vl_bc_subst_icms           as 'vBCST',--
--   ns.vl_icms_subst              as 'vST',--
--   ns.vl_produto                 as 'vProd',--
--   ns.vl_frete                   as 'vFrete',--
--   ns.vl_seguro                  as 'vSeg',--
--   ns.vl_desconto_nota_saida     as 'vDesc',--
--   ns.vl_ii                      as 'vII',  --
--   ns.vl_ipi                     as 'vIPI', --
--   ns.vl_pis                     as 'vPIS',--
--   ns.vl_cofins                  as 'vCOFINS',--
--   ns.vl_desp_acess              as 'vOutro',--
--   ns.vl_total                   as 'vNF',--

  --select * from nota_saida_item where cd_nota_saida = 611

--Para checagem dos valores.

--   ( select sum( isnull(nsi.vl_base_icms_item,0) ) 
--     from
--      nota_saida_item nsi 
--     where
--      nsi.cd_nota_saida = ns.cd_nota_saida ) as vl_base_icms_item,
-- 
--   ( select sum( isnull(nsi.vl_total_item,0) ) 
--     from
--      nota_saida_item nsi 
--     where
--      nsi.cd_nota_saida = ns.cd_nota_saida ) as vl_total_item,

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_bc_icms             > 0 then ns.vl_bc_icms       else null end,6,2)),103),'0.00')             as 'vBC',--
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_icms                > 0 then ns.vl_icms          else null end,6,2)),103),'0.00')             as 'vICMS',--
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_bc_subst_icms       > 0 then ns.vl_bc_subst_icms else null end,6,2)),103),'0.00')             as 'vBCST',--
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_icms_subst          > 0 then ns.vl_icms_subst    else null end,6,2)),103),'0.00')             as 'vST',--

  --07/02/2012 - Marcelo -  
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_produto             > 0 then ns.vl_produto       else null end,6,2)),103),'0.00')             as 'vProd',--  
  --isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_produto             > 0 then (select sum(round(nsi.qt_item_nota_saida * nsi.vl_unitario_item_nota,6,2)) from nota_saida_item nsi where nsi.cd_nota_saida = ns.cd_nota_saida ) else null end,6,2)),103),'0.00')   as 'vProd',--  
  --07/02/2012 - Marcelo -

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_frete               > 0 then ns.vl_frete         else null end,6,2)),103),'0.00')             as 'vFrete',--
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_seguro              > 0 then ns.vl_seguro        else null end,6,2)),103),'0.00')             as 'vSeg',--
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_desconto_nota_saida > 0 then ns.vl_desconto_nota_saida else null end,6,2)),103),'0.00')       as 'vDesc',--

  --Valor do Imposto de Importação
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_ii                  > 0 then ns.vl_ii            else null end,6,2)),103),'0.00')             as 'vII',  --

  --Valor do IPI

--  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_ipi                 > 0 then ns.vl_ipi           else null end,6,2)),103),'0.00')             as 'vIPI', --
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_ipi> 0 and isnull(ns.cd_finalidade_nfe,0)=4 and case when isnull(ef.cd_empresa,0) = 0 then isnull(emp.ic_simples_empresa,'N') else isnull(ef.ic_simples_empresa,'N') end = 'S'
  then null            else ns.vl_ipi end,6,2)),103),'0.00')             as 'vIPI', --


  --Valor do PIS  

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_pis                 > 0 then ns.vl_pis           else null end,6,2)),103),'0.00')             as 'vPIS',--
  --Valor do COFINS

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_cofins              > 0 then ns.vl_cofins        else null end,6,2)),103),'0.00')             as 'vCOFINS',--
  --Valor das Despesas Acessórias

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_desp_acess          > 0 then ns.vl_desp_acess   
  else 
    null
--   --Validação antes da Versão Norma Técnica 004/2011-----------------------------------------------------------------------------------------------------
-- 
--     case when isnull(opf.ic_materia_prima_aplicada,'N')='S' then
--         case when ( isnull(ns.vl_produto,0) - isnull(ns.vl_bc_icms,0) ) > 0 then isnull(ns.vl_produto,0) - isnull(ns.vl_bc_icms,0) else null end 
--     else
--       null
--     end

  end,6,2)),103),'0.00')                                                                                 as 'vOutro',--

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_total > 0 then ns.vl_total else null end,6,2)),103),'0.00')             as 'vNF',--

  'W17'                                                                                                  as 'ISSQNtot',--

--   ns.vl_servico as 'vServ',--
--   ns.vl_servico as 'vBCISS',
--   ns.vl_iss     as 'vISS',
 
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_servico       > 0 then ns.vl_servico else null end,6,2)),103),'0.00')                   as 'vServ',--
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_servico       > 0 then ns.vl_servico else null end,6,2)),103),'0.00')                   as 'vBCISS',
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when ns.vl_iss           > 0 then ns.vl_iss else null end,6,2)),103),'0.00')                       as 'vISS',
--  
  'W23'                                                                                              as 'retTrib',
 
 --Não Existe Campo no Egis-------------------------
  ''                                                                                           	      as 'vRetPIS',
  ''                                                                                                 as 'vRetCOFINS',
  ''                                                                                                 as 'vRetCSLL',
--  ns.vl_servico                                                                            as 'vBCIRRF',
--  ns.vl_irrf_nota_saida                                                                    as 'vIRRF',
--  ns.vl_servico                                                                            as 'vBCRetPrev',

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(ns.vl_servico,0)         > 0 then ns.vl_servico else null end,6,2)),103),'0.00')                                               as 'vBCIRRF',
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(ns.vl_irrf_nota_saida,0) > 0 then ns.vl_irrf_nota_saida else null end,6,2)),103),'0.00')                                       as 'vIRRF',
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(ns.vl_servico,0)         > 0 then ns.vl_servico else null end,6,2)),103),'0.00')                                               as 'vBCRetPrev',
  ''                                                                                                 as 'vRefPrev',

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(ns.vl_icms_desonerado,0) > 0 then ns.vl_icms_desonerado else null end,6,2)),103),'0.00') 
                                                                                                     as 'vICMSDeson',

--vl_total_tributos
--  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(ns.vl_total_tributos,0) > 0 then ns.vl_total_tributos else null end,6,2)),103),'0.00') 
--                                                                                                     as 'vTotTrib',

  dbo.fn_mascara_valor_duas_casas(case when isnull(opf.ic_importacao_op_fiscal,'N')='N' then 0.00 
  else 
     --isnull(ns.vl_pis,0)+isnull(ns.vl_cofins,0)
	 0.00
  end)                                               as 'vTotTrib',
 
-- incluir aqui o calculo do ST para o FCP
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(ns.vl_vFCPUFDest,0) > 0    then ns.vl_vFCPUFDest     else null end,6,2)),103),'0.00')  as 'vFCPUFDest',
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(ns.vl_vICMSUFDest,0)> 0    then ns.vl_vICMSUFDest    else null end,6,2)),103),'0.00')  as 'vICMSUFDest',
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(ns.vl_vICMSUFRemet,0) > 0  then ns.vl_vICMSUFRemet   else null end,6,2)),103),'0.00')  as 'vICMSUFRemet',
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(ns.vl_vFCP,0) > 0          then ns.vl_vFCP           else null end,6,2)),103),'0.00')  as 'vFCP',
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(ns.vl_vFCPST,0) > 0 and isnull(ns.vl_icms_subst,0) > 0 then ns.vl_vFCPST         else null end,6,2)),103),'0.00')  as 'vFCPST',
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(ns.vl_vFCPSTRet,0) > 0 and isnull(ns.vl_icms_subst,0) > 0 then ns.vl_vFCPSTRet     else null end,6,2)),103),'0.00')  as 'vFCPSTRet',
--  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(ns.vl_ipi_devolucao,0) > 0  then ns.vl_ipi_devolucao else null end,6,2)),103),'0.00')  as 'vIPIDevol',
 
 isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(ns.cd_finalidade_nfe,0)=4 and isnull(ns.vl_ipi,0)>0 and case when isnull(ef.cd_empresa,0) = 0 then isnull(emp.ic_simples_empresa,'N') else isnull(ef.ic_simples_empresa,'N') end = 'S'
  then isnull(ns.vl_ipi,0) else 0.00 end,6,2)),103),'0.00')                                                          as 'vIPIDevol',


  isnull(fcp.cd_identificacao_nfe,'')  as 'tPag',
  
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when cast(isnull(fcp.cd_identificacao_nfe,0) as int) not in (90,99) 
	  then isnull(ns.vl_total,0) else 0.00 end,6,2)),103),'0.00')         as 'vPag'--
                                                                                                                      



      
--select * from dI  

from
  nota_saida ns                                with (nolock) 
  left outer join operacao_fiscal opf          with (nolock) on opf.cd_operacao_fiscal   = ns.cd_operacao_fiscal
  left outer join condicao_pagamento cp        with (nolock) on cp.cd_condicao_pagamento = ns.cd_condicao_pagamento
  left outer join Forma_Condicao_Pagamento fcp with (nolock) on fcp.cd_forma_condicao    = cp.cd_forma_condicao
  left outer join egisadmin.dbo.empresa emp    with (nolock) on emp.cd_empresa           = dbo.fn_empresa()
  left outer join serie_nota_fiscal snf        with (nolock) on snf.cd_serie_nota_fiscal = ns.cd_serie_nota
  left outer join Empresa_Faturamento ef       with (nolock) on ef.cd_empresa            = snf.cd_empresa_selecao


--select * from operacao_fiscal

go

--select * from campo_arquivo_magnetico
------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select * from vw_nfe_produto_servico_nota_fiscal where cd_identificacao_nota_saida = 232
--select top 1000 * from vw_nfe_totais_nota_fiscal where cd_identificacao_nota_saida = 232 -- 222.62
-------------------------------------------------------------------------------------

--select top 10 * from nota_saida order by dt_nota_saida desc
--	
go