IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_parcela_nota_fiscal' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_parcela_nota_fiscal
GO


CREATE VIEW vw_nfe_parcela_nota_fiscal
------------------------------------------------------------------------------------
--sp_helptext vw_nfe_parcela_nota_fiscal
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2004
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSQL 
--
--Objetivo	        : Valores Totais da Nota Fiscal 
--                        para o sistema de emissão da Nota Fiscal Eletrônica
--
--Data                  : 05.11.2008
--Atualização           : 

--07.12.2018      -  Acerto nos campos vOrig, vLiq - Fagner Cardoso
--16.08.2022      - Acerto campo nFat - Numero NF -- Fagner Cardoso
------------------------------------------------------------------------------------
as
  
--select * from nota_saida_item  
--select * from nota_saida  
--select * from nota_saida_parcela  
  
select  
  
  ns.cd_nota_saida,  
  ns.cd_identificacao_nota_saida,

  --ns.cd_nota_saida                                            as nfat,  
  
 -- dbo.fn_strzero(ns.cd_nota_saida,9)                                                              as nfat,  

  --dbo.fn_strzero(ns.cd_identificacao_nota_saida,10)                                                as nfat,
  ns.cd_condicao_pagamento,
  isnull(cp.nm_condicao_pagamento,'')                                                                as nfat,
  cast(
    (select convert(numeric(14,2),sum(round(vl_parcela_nota_saida,13,2)),103)
	  from nota_saida_parcela 
	   where cd_nota_saida = ns.cd_nota_saida) as varchar)  as vOrig,   
   
  
  isnull(ns.vl_total,0)                                                                           as vl_total,                                                 
  
 isnull(CONVERT(varchar, convert(numeric(14,2),round(0.00,6,2)),103),'0.00')                      as vDesc,  
  
--  isnull(CONVERT(varchar, convert(numeric(14,2),round(ns.vl_total,6,2)),103),'0.00')              as vLiq,  
--  isnull(CONVERT(varchar, convert(numeric(14,2),round(nsp.vl_parcela_nota_saida,6,2)),103),'0.00') as vLiq, 

  cast(
    (select convert(numeric(14,2),sum(round(vl_parcela_nota_saida,6,2)),103)
	  from nota_saida_parcela 
	   where cd_nota_saida = ns.cd_nota_saida) as varchar)  as vLiq, 
  
  'Y07'                                                                                           as 'dup',  
  
  --nsp.cd_ident_parc_nota_saida                                                                     as nDup,  

      dbo.fn_strzero(nsp.cd_parcela_nota_saida,3)                                                      as nDup,
  
--  nsp.dt_parcela_nota_saida                                                                        as dVenc,  
--  ltrim(rtrim(replace(convert(char,nsp.dt_parcela_nota_saida,102),'.','-')))                       as dVenc,  

    ltrim( rtrim( dbo.fn_strzero(datepart(yyyy,nsp.dt_parcela_nota_saida),4) +'-'+
                  dbo.fn_strzero(datepart(mm,nsp.dt_parcela_nota_saida),2)   +'-'+
                  dbo.fn_strzero(datepart(dd,nsp.dt_parcela_nota_saida),2)   +'T'+
                   
                case when isnull(ns.hr_nota_saida,'')='' then
                  dbo.fn_hora_HHMMSS_NFE ( getdate() )
                else  
                  ns.hr_nota_saida
                end)) + case when isnull(v.ic_horario_verao,'N')='N' then '-03:00' else '-02:00' end as dVenc,
  
   isnull(CONVERT(varchar, convert(numeric(14,2),round(nsp.vl_parcela_nota_saida,6,2)),103),'0.00') as vDup,
   
   fcp.cd_identificacao_nfe                                                                      as 'tPag', 
   
   ltrim(rtrim(cast(isnull(ifp.cd_identificacao_nfe,0) as varchar(10))))                         as 'indPag',
   isnull(nsp.vl_parcela_nota_saida,0)                                                           as 'vPag',
   null                                                                                          as 'tpIntegra',
   null                                                                                          as 'tBand',
   null                                                                                          as 'cAut',
   null                                                                                          as 'CNPJPag',
   null                                                                                          as 'UFPag',
   null                                                                                          as 'CNPJReceb',
   null                                                                                          as 'idTermPag'

    
from  
  nota_saida ns                                 with (nolock)   
  inner join nota_saida_parcela nsp             with (nolock) on nsp.cd_nota_saida         = ns.cd_nota_saida  
  left outer join egisadmin.dbo.empresa e       with (nolock) on e.cd_empresa              = dbo.fn_empresa() 
  left outer join Versao_NFe v                  with (nolock) on v.cd_empresa              = e.cd_empresa and isnull(v.ic_ativa_versao_nfe,'N')='S'
  left outer join Condicao_Pagamento cp         with (nolock) on cp.cd_condicao_pagamento  = ns.cd_condicao_pagamento  
  left outer join Forma_Condicao_Pagamento fcp  with (nolock) on fcp.cd_forma_condicao     = cp.cd_forma_condicao
  left outer join Indicador_Forma_Pagamento ifp with (nolock) on ifp.cd_indicador                = cp.cd_indicador    
  
--select * from transportadora  
--select * from tipo_pagamento_frete  
--select * from nota_saida  
  



go


------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000000 * from vw_nfe_parcela_nota_fiscal where cd_nota_saida = 178815
------------------------------------------------------------------------------------

go