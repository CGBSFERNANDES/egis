IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_nota_item_diferimento' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_nota_item_diferimento
GO

CREATE VIEW vw_nfe_nota_item_diferimento
------------------------------------------------------------------------------------
--sp_helptext vw_nfe_nota_item_diferimento
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2015
------------------------------------------------------------------------------------
--Stored Procedure   : Microsoft SQL Server 2000 / 2008 / 2012 / 2014
--
--Autor(es)          : Carlos Cardoso Fernandes
--Banco de Dados     : EGISSQL 
--
--Objetivo           : NFE - Nota Fiscal Eletrônica
--                     Item do Diferimento do ICMS
--
--Data               : 10.01.2015
--Atualização        : 
--
------------------------------------------------------------------------------------
as
 
--select * from nota_saida_item_diferimento

select
  ns.cd_nota_saida,
  ns.cd_identificacao_nota_saida,
  ns.dt_nota_saida,
  nsd.cd_item_nota_saida,
--   nsd.vl_base_icms_item             as vBc,
--   nsd.pc_icms_item                  as picms,
--   nsd.vl_icms_item_operacao         as vicmsOp,
--   nsd.pc_icms_dif_item              as pdif,
--   nsd.vl_icms_diferido_item         as vicmsDif,
--   nsd.vl_icms_devido                as vicms,

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsd.vl_base_icms_item > 0 
  then nsd.vl_base_icms_item else null end,14,2)),103),'0.00')                                                       as 'vBC',

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsd.pc_icms_item > 0 
  then nsd.pc_icms_item else null end,14,2)),103),'0.00')                                                            as 'picms',

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsd.vl_icms_item_operacao > 0 
  then nsd.vl_icms_item_operacao else null end,14,2)),103),'0.00')                                                   as 'vicmsOp',

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsd.pc_icms_dif_item > 0 
  then nsd.pc_icms_dif_item else null end,14,2)),103),'0.00')                                                        as 'pdif',

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsd.vl_icms_diferido_item > 0 
  then nsd.vl_icms_diferido_item else null end,14,2)),103),'0.00')                                                   as 'vicmsDif',

  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsd.vl_icms_devido > 0 
  then nsd.vl_icms_devido else null end,14,2)),103),'0.00')                                                          as 'vicms',



  nsd.cd_usuario,
  nsd.dt_usuario

from
  nota_saida ns
  inner join nota_saida_item nsi             on nsi.cd_nota_saida      = ns.cd_nota_saida
  inner join nota_saida_item_diferimento nsd on nsd.cd_nota_saida      = nsi.cd_nota_saida      and
                                                nsd.cd_item_nota_saida = nsi.cd_item_nota_saida
       


go


------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_nfe_nota_item_diferimento
------------------------------------------------------------------------------------

go