IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_icms_nota_fiscal' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_icms_nota_fiscal
GO

CREATE VIEW vw_nfe_icms_nota_fiscal
------------------------------------------------------------------------------------
--sp_helptext vw_nfe_icms_nota_fiscal
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2004
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSQL 
--
--Objetivo	        : Identificação do Local da Retirada da Nota Fiscal 
--                        para o sistema de emissão da Nota Fiscal Eletrônica
--
--Data                  : 05.11.2008
--Atualização           : 04.04.2009 - Ajuste da Tributação - Carlos
------------------------------------------------------------------------------------
as


select
  ns.dt_nota_saida,
  nsi.cd_nota_saida,
  nsi.cd_item_nota_saida,
  nsi.cd_produto,
  nsi.nm_fantasia_produto,

  --'N'                                                            as 'icms',

  --Tag de Acordo com a Tributação do Produto
  isnull(ti.sg_tab_nfe_tributacao,'N06')                         as 'icms',

  'N02'                                                          as 'ICMS00',

  rtrim(ltrim(cast(pp.cd_digito_procedencia as varchar(1))))     as 'orig',
  rtrim(ltrim(cast(ti.cd_digito_tributacao_icms as varchar(2)))) as 'CST',
  rtrim(ltrim(cast(mci.cd_digito_modalidade  as varchar(1))))    as 'modBC',
  isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.vl_base_icms_item,6,2)),103),'')           as 'vBC',
  isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.pc_icms,6,2)),103),'')                     as 'pICMS',
  isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.vl_icms_item,6,2)),103),'')                as 'vICMS',
  ltrim(rtrim(cast(mct.cd_digito_modalidade_st as varchar(10))))                                     as 'modBCST',

  --Este campo não tem no Egis
  isnull(CONVERT(varchar, convert(numeric(14,2),round(
  case when isnull(pf.pc_iva_icms_produto,0)>0 and isnull(cfe.ic_icms_pauta_classificacao,'N') = 'N' then
    pf.pc_iva_icms_produto
  else
    case when isnull(cf.pc_subst_classificacao,0)>0 and isnull(cfe.ic_icms_pauta_classificacao,'N') = 'N'then
      isnull(cf.pc_subst_classificacao,0)
    else
      case when isnull(cfe.pc_icms_strib_clas_fiscal,0) > 0 and isnull(cfe.ic_icms_pauta_classificacao,'N') = 'N' then
        isnull(cfe.pc_icms_strib_clas_fiscal,0)
      else
        null
      end
      --select * from classificacao_fiscal_estado
    end
  end,6,2)),103),'')                           as 'pMVAST',
  
  --(%) de Redução da Base de Cálculo

  isnull(CONVERT(varchar, convert(numeric(14,2),round(isnull(cfe.pc_redu_icms_class_fiscal,0),6,2)),103),'')        as 'pRedBCST',
  case when isnull(nsi.vl_bc_subst_icms_item,0) > 0 then
  isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.vl_bc_subst_icms_item,6,2)),103),'') 
  else
  '' 
  end as 'vBCST',
  
  case when isnull(nsi.vl_bc_subst_icms_item,0) > 0 then
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(cfe.pc_icms_strib_clas_fiscal,0)>0 and isnull(cfe.ic_icms_pauta_classificacao,'N') = 'N' then
                                                        isnull(cfe.pc_icms_strib_clas_fiscal,0)
                                                      else
                                                        isnull(nsi.pc_icms,0)
                                                      end,6,2)),103),'')  else '' end                        as 'pICMSST',
  
  case when isnull(nsi.vl_icms_subst_icms_item,0) > 0 then
  isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.vl_icms_subst_icms_item,6,2)),103),'')
  else
  ''
  end                 as 'vICMSST',

  isnull(CONVERT(varchar, convert(numeric(14,2),round(isnull(cfe.pc_redu_icms_class_fiscal,0),6,2)),103),'0.00')         as 'pREDBC',

  'N03'                                                                          as 'ICMS10',
  'N04'                                                                          as 'ICMS20',
  'N05' 	                                                                     as 'ICMS30',
  'N06'                                                                          as 'ICMS40',
  'N07'                                                                          as 'ICMS51',
  'N08'                                                                          as 'ICMS60',
  'N09'                                                                          as 'ICMS70',
  'N10'                                                                          as 'ICMS90',
  isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.vl_bc_subst_icms_item,6,2)),103),'')   as vBCSTRet,
  isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.pc_icms,6,2)),103),'')                 as pST,
  isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.vl_icms_item,6,2)),103),'')            as vICMSSubstituto,
  isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.vl_icms_subst_icms_item,6,2)),103),'') as vICMSSTRet,
    --Fundo de combate a Pobreza--
  case when isnull(ic_contribicms_op_fiscal,'N') = 'N' and isnull(nsi.vBCFCP,0) > 0 then nsi.vBCFCP else '' end  as 'vBCFCPST',
  case when isnull(ic_contribicms_op_fiscal,'N') = 'N' and isnull(nsi.pFCP,0)   > 0 then nsi.pFCP   else '' end  as 'pFCPST',
  case when isnull(ic_contribicms_op_fiscal,'N') = 'N' and isnull(nsi.vFCP,0)   > 0 then nsi.vFCP   else '' end  as 'vFCPST',
   --Difal---
  case when isnull(ic_contribicms_op_fiscal,'N') = 'N' and isnull(nsi.vl_base_difal,0)            > 0 then isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.vl_base_difal           ,6,2)),103),'') else null end as vBCUFDest,
  case when isnull(ic_contribicms_op_fiscal,'N') = 'N' and isnull(nsi.vBCFCP,0)                   > 0 then isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.vBCFCP                  ,6,2)),103),'') else null end as vBCFCPUFDest,
  case when isnull(ic_contribicms_op_fiscal,'N') = 'N' and isnull(nsi.pFCP,0)                     > 0 then isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.pFCP                    ,6,2)),103),'') else null end as pFCPUFDest,
  case when isnull(ic_contribicms_op_fiscal,'N') = 'N' and isnull(nsi.pc_icms,0)                  > 0 then isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.pc_icms                 ,6,2)),103),'') else null end as pICMSUFDest,
  case when isnull(ic_contribicms_op_fiscal,'N') = 'N' and isnull(cfe.pc_interna_icms_clas_fis,0) > 0 then isnull(CONVERT(varchar, convert(numeric(14,2),round(cfe.pc_interna_icms_clas_fis,6,2)),103),'') else null end as pICMSInter,
  case when isnull(ic_contribicms_op_fiscal,'N') = 'N'                                                then isnull(CONVERT(varchar, convert(numeric(14,2),round(100                         ,6,2)),103),'') else null end as pICMSInterPart,
  case when isnull(ic_contribicms_op_fiscal,'N') = 'N' and isnull(nsi.vFCP,0)                     > 0 then isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.vFCP                    ,6,2)),103),'') else null end as vFCPUFDest,
  case when isnull(ic_contribicms_op_fiscal,'N') = 'N' and isnull(nsi.vl_difal,0)                 > 0 then isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.vl_difal                ,6,2)),103),'') else null end as vICMSUFDest,
  case when isnull(ic_contribicms_op_fiscal,'N') = 'N'                                                then isnull(CONVERT(varchar, convert(numeric(14,2),round(0.00                        ,6,2)),103),'') else null end as vICMSUFRemet


  --isnull(cf.pc_subst_classificacao,0)                            as 'pRedBCST'                  
 
  
from
  nota_saida ns                                     with (nolock)
  left outer join estado e                          with (nolock) on ns.sg_estado_nota_saida     = e.sg_estado
  inner join nota_saida_item nsi                    with (nolock) on nsi.cd_nota_saida           = ns.cd_nota_saida
  left outer join produto        p                  with (nolock) on p.cd_produto                = nsi.cd_produto
  left outer join produto_fiscal pf                 with (nolock) on pf.cd_produto               = p.cd_produto
  left outer join procedencia_produto pp            with (nolock) on pp.cd_procedencia_produto   = nsi.cd_procedencia_produto
  left outer join tributacao t                      with (nolock) on t.cd_tributacao             = nsi.cd_tributacao
  left outer join tributacao_icms ti                with (nolock) on ti.cd_tributacao_icms       = t.cd_tributacao_icms
  left outer join modalidade_calculo_icms mci       with (nolock) on mci.cd_modalidade_icms      = t.cd_modalidade_icms
  left outer join modalidade_calculo_icms_sTrib mct with (nolock) on mct.cd_modalidade_icms_st   = t.cd_modalidade_icms_st
  left outer join classificacao_fiscal cf           with (nolock) on cf.cd_classificacao_fiscal  = nsi.cd_classificacao_fiscal
  left outer join classificacao_fiscal_estado cfe   with (nolock) on cfe.cd_classificacao_fiscal = nsi.cd_classificacao_fiscal and
                                                                     cfe.cd_estado               = e.cd_estado
  left outer join Operacao_Fiscal opf               with (nolock) on opf.cd_operacao_fiscal      = nsi.cd_operacao_fiscal
           
--select * from classificacao_fiscal_estado where cd_estado = 26

--select * from procedencia_produto
--select * from tributacao_icms
--select * from nota_saida_item where cd_nota_saida = 38
--select cd_estado,* from nota_saida
--select * from modalidade_calculo_icms
go

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_nfe_icms_nota_fiscal
------------------------------------------------------------------------------------
--select top 1000 pICMSInter, * from vw_nfe_icms_nota_fiscal WHERE cd_nota_saida = 60302

-- select * from nota_saida_item where cd_nota_saida = 38
-- select * from produto where cd_produto = 1997
-- select * from produto_fiscal where cd_produto = 1997
-- -- 
-- update
--   nota_saida_item
-- set
--   cd_produto = p.cd_produto
-- from
--   nota_saida_item i
--   inner join produto p on p.nm_fantasia_produto = i.nm_fantasia_produto
-- where
--   p.cd_produto <> i.cd_produto
-- 
-- 
-- select 
--   p.cd_produto,
--   p.cd_mascara_produto
-- from
--   produto p
-- where
--   p.cd_produto not in ( select cd_produto from produto_fiscal where cd_produto = p.cd_produto)
--use egissql_274
go