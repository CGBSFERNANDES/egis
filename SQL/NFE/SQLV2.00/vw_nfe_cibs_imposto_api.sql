IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_cibs_imposto_api' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_cibs_imposto_api

GO

------------------------------------------------------------------------------------ 
--sp_helptext vw_nfe_cibs_imposto_api
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                            2024
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSvuntribQL 
--
--Objetivo	        : Identificação do Detalhe Produto/Serviço da Nota Fiscal 
--                        paralote o sistema de emissão da Nota Fiscal Eletrônica
--
--Data                  : 05.11.2008
--Atualização           : 23.11.2008 - Ajustes Diversos - Carlos Fernandes
------------------------------------------------------------------------------------------------------------------------------- 
CREATE VIEW vw_nfe_cibs_imposto_api            
as            
            
select            
  ns.cd_identificacao_nota_saida,            
  ns.dt_nota_saida,            
  nsi.cd_nota_saida,            
  nsi.cd_item_nota_saida,            
  nsi.cd_item_nota_saida                       as 'nItem',

   /* ===== Campos para IBSCBS (ITEM) =====
       Preencha os NULLs abaixo mapeando das suas tabelas de regra/tributação.
       Tipos e nomes batem com o que você precisa no JSON -> XML:
         - CST:        varchar(3)   (ex.: '000', '050', ...)
         - cClassTrib: varchar(6)   (classificação tributária)
         - vBC:        decimal(15,2)
         - pIBSUF:     decimal(15,4)
         - vIBSUF:     decimal(15,2)
         - pIBSMun:    decimal(15,4)
         - vIBSMun:    decimal(15,2)
         - pCBS:       decimal(15,4)
         - vCBS:       decimal(15,2)
    */

    ---------------------------------------------------------------------------------
    --as aliquotas de impostos de 1/1/2026 tem que vir da tabela nota_saida_item
    --pc_cbs, pc_ibs, pc_ibs_estadual, pc_ibs_municipal, pc_is
    --bases de cálculos--> vl_bc_cbs, vl_bc_ibs, vl_bc_is 
    ---------------------------------------------------------------------------------

    cast(st.cd_identificacao AS varchar(3))             as CST,
    cast(ct.cd_identificacao AS varchar(6))             as cClassTrib,
    case when ISNULL(st.ic_calculo_imposto,'S') = 'S' and isnull(opf.ic_comercial_operacao,'S') = 'S' then
      case when 
      (cast(((isnull(nsi.vl_total_item,0)+
             isnull(nsi.vl_frete_item,0)+
             isnull(nsi.vl_desp_acess_item,0)) 
             -
            (isnull(nsi.vl_pis,0)+
             isnull(nsi.vl_cofins,0)+
             isnull(nsi.vl_icms_item,0)+
             isnull(nsi.vl_difal,0))) as decimal(15,2))) >= 0 then 
             cast(((isnull(nsi.vl_total_item,0)+
             isnull(nsi.vl_frete_item,0)+
             isnull(nsi.vl_desp_acess_item,0)) 
             -
            (isnull(nsi.vl_pis,0)+
             isnull(nsi.vl_cofins,0)+
             isnull(nsi.vl_icms_item,0)+
             isnull(nsi.vl_difal,0))) as decimal(15,2)) 
        else
          cast(((isnull(nsi.vl_total_item,0)+
             isnull(nsi.vl_frete_item,0)+
             isnull(nsi.vl_desp_acess_item,0)) 
             -
            (isnull(nsi.vl_pis,0)+
             isnull(nsi.vl_cofins,0)+
             isnull(nsi.vl_icms_item,0)+
             isnull(nsi.vl_difal,0))) as decimal(15,2)) * -1
       end
    else
      0.00
    end as vBC,     -- Base IBS/CBS do item
       
    case when isnull(st.ic_calculo_imposto,'S') = 'S' then
      cast(0.1 AS decimal(15,4))             
    else 
      0.00
    end                                                 AS pIBSUF,  -- Alíquota IBS UF
    case when ISNULL(st.ic_calculo_imposto,'S') = 'S'
         and st.cd_identificacao      = 200     -- CST 2N0
         and ct.cd_identificacao      = 200003  -- Cesta básica 
    then
      0.00
    else
     case when ISNULL(st.ic_calculo_imposto,'S') = 'S' and isnull(opf.ic_comercial_operacao,'S') = 'S' then
      round( ((case when 
      (cast(((isnull(nsi.vl_total_item,0)+
             isnull(nsi.vl_frete_item,0)+
             isnull(nsi.vl_desp_acess_item,0)) 
             -
            (isnull(nsi.vl_pis,0)+
             isnull(nsi.vl_cofins,0)+
             isnull(nsi.vl_icms_item,0)+
             isnull(nsi.vl_difal,0))) as decimal(15,2))) >= 0 then 
             cast(((isnull(nsi.vl_total_item,0)+
             isnull(nsi.vl_frete_item,0)+
             isnull(nsi.vl_desp_acess_item,0)) 
             -
            (isnull(nsi.vl_pis,0)+
             isnull(nsi.vl_cofins,0)+
             isnull(nsi.vl_icms_item,0)+
             isnull(nsi.vl_difal,0))) as decimal(15,2)) 
        else
          (cast(((isnull(nsi.vl_total_item,0)+
             isnull(nsi.vl_frete_item,0)+
             isnull(nsi.vl_desp_acess_item,0)) 
             -
            (isnull(nsi.vl_pis,0)+
             isnull(nsi.vl_cofins,0)+
             isnull(nsi.vl_icms_item,0)+
             isnull(nsi.vl_difal,0))) as decimal(15,2)) * -1)
       end * 0.1) / 100),2)
      else
        0.00
      end
    end                                                 as vIBSUF,  -- Valor IBS UF
    cast(0.00 AS decimal(15,4))                         as pIBSMun, -- Alíquota IBS Mun
    cast(0.00 AS decimal(15,2))                         as vIBSMun, -- Valor IBS Mun
        -- Base IBS/CBS do item
    case when isnull(st.ic_calculo_imposto,'S') = 'S' then
      cast(0.9 as decimal(15,4))       
    else
      0.00
    end                                                 AS pCBS,    -- Alíquota CBS
    case when isnull(st.ic_calculo_imposto,'S') = 'S'
         and st.cd_identificacao      = 200     -- CST 200
         and ct.cd_identificacao      = 200003  -- Cesta básica 
    then
      0.00
    else
      case when isnull(st.ic_calculo_imposto,'S') = 'S' and isnull(opf.ic_comercial_operacao,'S') = 'S' then
      round(((case when 
      (cast(((isnull(nsi.vl_total_item,0)+
             isnull(nsi.vl_frete_item,0)+
             isnull(nsi.vl_desp_acess_item,0)) 
             -
            (isnull(nsi.vl_pis,0)+
             isnull(nsi.vl_cofins,0)+
             isnull(nsi.vl_icms_item,0)+
             isnull(nsi.vl_difal,0))) as decimal(15,2))) >= 0 then 
             cast(((isnull(nsi.vl_total_item,0)+
             isnull(nsi.vl_frete_item,0)+
             isnull(nsi.vl_desp_acess_item,0)) 
             -
            (isnull(nsi.vl_pis,0)+
             isnull(nsi.vl_cofins,0)+
             isnull(nsi.vl_icms_item,0)+
             isnull(nsi.vl_difal,0))) as decimal(15,2)) 
        else
          cast(((isnull(nsi.vl_total_item,0)+
             isnull(nsi.vl_frete_item,0)+
             isnull(nsi.vl_desp_acess_item,0)) 
             -
            (isnull(nsi.vl_pis,0)+
             isnull(nsi.vl_cofins,0)+
             isnull(nsi.vl_icms_item,0)+
             isnull(nsi.vl_difal,0))) as decimal(15,2)) * -1
       end * 0.9)/100),2)
      else
        0.00
      end
    end                                                 as vCBS,     -- Valor CBS

    --Redução---

    -----------------------------------------------------------------
    -- NOVOS CAMPOS: redução de alíquota (gRed) – exemplo Cesta Básica
    -----------------------------------------------------------------
    -- Aqui estou assumindo: CST = 200 e cClassTrib = 200003
    --  => redução de 100% (cesta básica nacional – Anexo I)
    CAST(
      CASE 
        WHEN ISNULL(st.ic_calculo_imposto,'S') = 'S'
         AND st.cd_identificacao      = 200     -- CST 200
         AND ct.cd_identificacao      = 200003  -- Cesta básica
        THEN 100.0000
        ELSE 0.0000
      END AS decimal(15,4)
    )                                           AS pRedAliqIBSUF,

    CAST(
      CASE 
        WHEN ISNULL(st.ic_calculo_imposto,'S') = 'S'
           AND st.cd_identificacao      = 200
           AND ct.cd_identificacao      = 200003
        THEN 0.0000      -- alíquota efetiva = zero
        ELSE
          CASE WHEN ISNULL(st.ic_calculo_imposto,'S') = 'S' and isnull(opf.ic_comercial_operacao,'S') = 'S'
               THEN 0.1000
               ELSE 0.0000
          END
      END AS decimal(15,4)
    )                                           AS pAliqEfetIBSUF,

    CAST(
      CASE 
        WHEN ISNULL(st.ic_calculo_imposto,'S') = 'S'
         AND st.cd_identificacao      = 200
         AND ct.cd_identificacao      = 200003
        THEN 100.0000
        ELSE 0.0000
      END AS decimal(15,4)
    )                                           AS pRedAliqCBS,

    CAST(
      CASE 
        WHEN ISNULL(st.ic_calculo_imposto,'S') = 'S'
          AND st.cd_identificacao      = 200
          AND ct.cd_identificacao      = 200003
        THEN 0.0000      -- efetiva zero
        ELSE
          CASE WHEN ISNULL(st.ic_calculo_imposto,'S') = 'S' and isnull(opf.ic_comercial_operacao,'S') = 'S'
               THEN 0.9000
               ELSE 0.0000
          END
      END AS decimal(15,4)
    )                                           AS pAliqEfetCBS,
    ISNULL(st.ic_calculo_imposto,'S')           as ic_calculo_imposto


    /*
    /* Bases: preferir bases específicas, caindo para vl_total_item se nulas */
  CAST(ISNULL(NULLIF(nsi.vl_bc_ibs,0), nsi.vl_total_item) AS decimal(15,2)) AS vBC,

  /* IBS – UF */
  CAST(ISNULL(nsi.pc_ibs_estadual,0) AS decimal(15,4))     AS pIBSUF,
  CAST( ISNULL(NULLIF(nsi.vl_bc_ibs,0), nsi.vl_total_item)
        * ISNULL(nsi.pc_ibs_estadual,0) / 100.0
        AS decimal(15,2))                                   AS vIBSUF,

  /* IBS – Município */
  CAST(ISNULL(nsi.pc_ibs_municipal,0) AS decimal(15,4))     AS pIBSMun,
  CAST( ISNULL(NULLIF(nsi.vl_bc_ibs,0), nsi.vl_total_item)
        * ISNULL(nsi.pc_ibs_municipal,0) / 100.0
        AS decimal(15,2))                                   AS vIBSMun,

  /* CBS */
  CAST(ISNULL(nsi.pc_cbs,0) AS decimal(15,4))               AS pCBS,
  CAST( ISNULL(NULLIF(nsi.vl_bc_cbs,0), nsi.vl_total_item)
        * ISNULL(nsi.pc_cbs,0) / 100.0
        AS decimal(15,2))                                   AS vCBS

FROM no
    */
  

            
from            
  nota_saida ns                                     with (nolock)             
  inner join nota_saida_item nsi                    with (nolock) on nsi.cd_nota_saida             = ns.cd_nota_saida            
  left outer join produto_fiscal pf                 with (nolock) on pf.cd_produto                 = nsi.cd_produto
  
  left outer join classificacao_fiscal cf           with (nolock) on cf.cd_classificacao_fiscal    = case when isnull(nsi.cd_classificacao_fiscal,0)>0 then
                                                                                                       nsi.cd_classificacao_fiscal 
																									 else
																									   pf.cd_classificacao_fiscal
																									 end

  left outer join unidade_medida cfu                    with (nolock) on cfu.cd_unidade_medida         = cf.cd_unidade_medida            
  left outer join operacao_fiscal opf                   with (nolock) on opf.cd_operacao_fiscal        = nsi.cd_operacao_fiscal            

  left outer join procedencia_produto pp                with (nolock) on pp.cd_procedencia_produto     = nsi.cd_procedencia_produto            
  left outer join tributacao t                          with (nolock) on t.cd_tributacao               = nsi.cd_tributacao            
  left outer join situacao_tributaria st                with (nolock) on st.cd_situacao_tributaria     = t.cd_situacao_tributaria
  --left outer join Situacao_Classificacao_Tributaria sct with (nolock) on sct.cd_situacao_tributaria    = t.cd_situacao_tributaria
  left outer join classificacao_tributaria ct           with (nolock) on ct.cd_classificacao           = t.cd_classificacao
  
  left outer join produto                       p       with (nolock) on p.cd_produto                  = nsi.cd_produto        

GO

--select * from nota_validacao

--SELECT cd_tributacao, * from nota_saida_item where cd_nota_saida = 266
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--select vIBSUF, * from vw_nfe_cibs_imposto_api  where cd_nota_saida = 987132
--select cast(sum(vIBSUF) as decimal(15,2)) from vw_nfe_cibs_imposto_api  where cd_nota_saida = 987132
------------------------------------------------------------------------------------------------------------------------------------------------------------------------