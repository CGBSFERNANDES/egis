IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_emitente_nota_fiscal' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_emitente_nota_fiscal
GO

CREATE VIEW vw_nfe_emitente_nota_fiscal
------------------------------------------------------------------------------------
--sp_helptext vw_nfe_emitente_nota_fiscal
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2004
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSQL 
--
--Objetivo	        : Identificação da Nota Fiscal 
--                        para o sistema de emissão da Nota Fiscal Eletrônica
--
--Data                  : 04.11.2008
--Atualização           : 26.08.2009 - Ajustes da consistência do Cep - Carlos/Luis
-- 14.08.2010 - Complemento de Endereço - Carlos Fernandes
-- 23.09.2010 - Modificação do tamanho do telefone lay-out v2.0 - Carlos / Luis 
-- 24.04.2014 - filtro da empresa por série da Nota Fiscal - Carlos Fernandes
-- 06.07.2021 - Inclusão da Empresa Faturamento -- Fagner Cardoso
------------------------------------------------------------------------------------

as

--select * from versao_nfe
--select * from forma_condicao_pagamento

select
  ns.cd_identificacao_nota_saida,
  ns.dt_nota_saida,
  ns.cd_nota_saida,
  'C'                                                                         as 'emit',
  rtrim(ltrim(cast(case when isnull(sn.cd_empresa_selecao,0)<>0 and isnull(ef.nm_empresa,'')<>'' 
                   then
                      ef.nm_empresa
				   else
			          e.nm_empresa 
				   end          as varchar(60))))                             as 'xNome',                                       
  rtrim(ltrim(cast(case when isnull(sn.cd_empresa_selecao,0)<>0 and isnull(ef.nm_fantasia_empresa,'') <> '' 
                   then
                      ef.nm_fantasia_empresa
				   else
			          e.nm_fantasia_empresa 
				   end          as varchar(60))))                             as 'xFant',

  rtrim(ltrim(replace(replace(replace(cast(case when isnull(sn.cd_empresa_selecao,0)<>0 and isnull(ef.cd_ie_empresa,'')<>''
                                           then
                                              ef.cd_ie_empresa
										   else
										      e.cd_iest_empresa 
										   end as varchar(16)),'.',''),'-',''),'/',''))) as 'IE',

  case when isnull(ns.vl_icms_subst,0) > 0 then
	  case when eis.cd_inscestadual_subistituto is null or ltrim(rtrim(eis.cd_inscestadual_subistituto)) = '' then 
		  case when e.cd_iest_st_empresa is null or ltrim(rtrim(e.cd_iest_st_empresa)) = '' then 
		    ''
		  else 
		    replicate('0', 14 - len(rtrim(ltrim(cast(e.cd_iest_st_empresa as varchar(14)))))) +
		    rtrim(ltrim(cast(e.cd_iest_st_empresa as varchar(14)))) 
	    end
	  else
	    replicate('0', 14 - len(rtrim(ltrim(cast(eis.cd_inscestadual_subistituto as varchar(14)))))) +
	    rtrim(ltrim(cast(eis.cd_inscestadual_subistituto as varchar(14)))) 
    end
  else
    ''
  end                                                                         as 'IEST',

  case when e.nm_inscricao_municipal is null or ltrim(rtrim(e.nm_inscricao_municipal)) = '' then 
    replicate('0',15)
  else 
    replicate('0', 15 - len(rtrim(ltrim(cast(e.nm_inscricao_municipal as varchar(15)))))) +
    rtrim(ltrim(cast(e.nm_inscricao_municipal as varchar(15)))) 

  end                                                                            as 'IM',

  --Código do CNAE---------------------------------------------------------------------------
 
  case when e.cd_cnae is null or ltrim(rtrim(e.cd_cnae)) = '' then 
    ''
  else 
    replicate('0', 7 - len(rtrim(ltrim(cast(e.cd_cnae as varchar(7)))))) +
    rtrim(ltrim(cast(e.cd_cnae as varchar(7)))) 

  end                                                                                          as 'CNAE',

  'C02'                                                                                        as 'C02',

  cast(dbo.fn_Formata_Mascara('00000000000000', case when isnull(sn.cd_empresa_selecao,0)<>0 
  and isnull( ef.cd_cnpj_empresa,'') <> ''      then
                                                   ef.cd_cnpj_empresa
												else
												   e.cd_cgc_empresa 
												end)              as varchar(14))              as 'CNPJ',

  cast('' as varchar(14))                                                                      as 'CPF',

  'C05'                                                                                        as 'enderEmit',
  cast(rtrim(ltrim(isnull(case when isnull(sn.cd_empresa_selecao,0)<>0 and isnull(ef.nm_endereco,'')<> '' then
                             ef.nm_endereco
						  else
						     e.nm_endereco_empresa
					      end,''))) as varchar(60) )                                           as 'xLgr',

  cast(rtrim(ltrim(isnull(case when isnull(sn.cd_empresa_selecao,0)<>0 then
                             ef.nm_complemento 
						  else
						     e.nm_complemento_endereco
						  end,''))) as varchar(60))                                            as 'xCpl',
  
  ltrim(rtrim(cast(isnull(case when isnull(sn.cd_empresa_selecao,0)<>0 and isnull(ef.cd_numero,'')<>'' then
                             ef.cd_numero
						  else
							 e.cd_numero
					      end,'') as varchar(8))))                                             as 'nro', 

  ltrim(rtrim(cast(isnull(case when isnull(sn.cd_empresa_selecao,0)<>0 and isnull(ef.nm_bairro,'')<>'' then
                             ef.nm_bairro
						  else
                             e.nm_bairro_empresa
						  end,'') as varchar(60))))                                            as 'xBairro',

  ltrim(rtrim(cast(cid.cd_cidade_ibge as varchar(8))))                                         as 'cMun',  
  ltrim(rtrim(cast(cid.nm_cidade as varchar(60))))                                             as 'xMun',
  ltrim(rtrim(cast(est.sg_estado as varchar(2))))                                              as 'UF',

  -- Carlos Fernandes
 
  replicate('0', 8 - len(rtrim(ltrim(cast(replace(case when isnull(sn.cd_empresa_selecao,0)<>0 and isnull(ef.cd_cep,'')<>'' then
                                                     ef.cd_cep
												  else
													 e.cd_cep
												  end,'-','') as varchar(8)))))) +
  rtrim(ltrim(cast(replace(case when isnull(sn.cd_empresa_selecao,0)<>0 and isnull(ef.cd_cep,'')<>''  then
                                                     ef.cd_cep
												  else
													 e.cd_cep
												  end,'-','') as varchar(8))))                 as 'CEP',  
 
  ltrim(rtrim(cast(p.cd_bacen_pais as varchar(8))))                                            as 'cPais',
  ltrim(rtrim(cast(p.nm_pais as varchar(20))))                                                 as 'xPais',

  --select * from egisadmin.dbo.empresa
  cast(
  
 -- case when e.cd_telefone_empresa is null then
 --   '' 
 -- else 
    case when substring(ltrim(rtrim(cast(replace(replace(replace(replace(case when isnull(sn.cd_empresa_selecao,0)<>0 then
	                                                                        ef.cd_telefone
																		 else
																			e.cd_telefone_empresa
																		 end,'-',''),' ',''),'(',''),')','') as varchar(12)))),1,1) = '0' then
      substring(ltrim(rtrim(cast(replace(replace(replace(replace(case when isnull(sn.cd_empresa_selecao,0)<>0 then
	                                                                        ef.cd_telefone
																		 else
																			e.cd_telefone_empresa
																		 end,'-',''),' ',''),'(',''),')','') as varchar(12)))),2,12)    
    else
      ltrim(rtrim(cast(replace(replace(replace(replace(case when isnull(sn.cd_empresa_selecao,0)<>0 then
	                                                                        ef.cd_telefone
																		 else
																			e.cd_telefone_empresa
																		 end,'-',''),' ',''),'(',''),')','') as varchar(12))))    
    end 
  --end  
    as varchar(14))                                                                            as 'fone',

  --Código de Regime para Simples Nacional
  cast(isnull(rt.cd_nfe_regime,'') as char(1))                                                 as 'C21_CRT',
  isnull(ef.nm_diretorio_xml_nfe,'') as 'nm_diretorio_xml_nfe' 
   
  --select * from regime_tributario

from
  nota_saida                        ns     with (nolock)
  left outer join cliente           cli    with (nolock) on cli.cd_cliente           = ns.cd_cliente
  left outer join serie_nota_fiscal sn     with (nolock) on sn.cd_serie_nota_fiscal  = ns.cd_serie_nota
  left outer join egisadmin.dbo.empresa e  with (nolock) on e.cd_empresa             = case when isnull(sn.cd_empresa,0)<>0 
                                                                                      then
                                                                                        sn.cd_empresa 
                                                                                      else
                                                                                        dbo.fn_empresa()
                                                                                      end
  left outer join empresa_inscricao_substituto eis with (nolock) on eis.cd_empresa  = case when isnull(sn.cd_empresa,0)<>0 
                                                                                      then
                                                                                        sn.cd_empresa 
                                                                                      else
                                                                                        dbo.fn_empresa()
                                                                                      end
                                                                and eis.cd_estado   = cli.cd_estado
  left outer join Empresa_Faturamento ef   with (nolock) on ef.cd_empresa           = sn.cd_empresa_selecao
  left outer join cnae  c                  with (nolock) on c.cd_cnae               = e.cd_cnae
  left outer join Pais  p                  with (nolock) on p.cd_pais               = case when isnull(sn.cd_empresa_selecao,0) <>0 then
                                                                                         ef.cd_pais
																					  else                                                                                        
																						 e.cd_pais
																					  end
  left outer join Estado est               with (nolock) on est.cd_estado           = case when isnull(sn.cd_empresa_selecao,0) <>0 then
                                                                                         ef.cd_estado
																					  else                                                                                        
																						 e.cd_estado
																					  end
  left outer join Cidade cid               with (nolock) on cid.cd_estado           = case when isnull(sn.cd_empresa_selecao,0) <>0 and isnull(ef.cd_estado,0)>0
                                                                                      then
                                                                                         ef.cd_estado
																					  else                                                                                        
																						 e.cd_estado
																					  end and
                                                            cid.cd_cidade           = case when isnull(sn.cd_empresa_selecao,0) <>0 and isnull(ef.cd_cidade,0)>0
															                          then
                                                                                         ef.cd_cidade
																					  else                                                                                        
																						 e.cd_cidade
																					  end

  left outer join versao_nfe v             with (nolock) on v.cd_empresa            = e.cd_empresa

  left outer join regime_tributario rt     with (nolock) on rt.cd_regime_tributario = case when isnull(sn.cd_empresa_selecao,0)<>0 and isnull(ef.cd_regime_tributario,0)>0
                                                                                      then
                                                                                         ef.cd_regime_tributario
																					  else
																						 v.cd_regime_tributario
																					  end

--where
--  isnull(ns.ic_nfe_nota_saida,'N') = 'N'

go

--select * from egisadmin.dbo.empresa
--select cd_tipo_operacao_fiscal,* from nota_saida

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_nfe_emitente_nota_fiscal where cd_nota_saida = 1
------------------------------------------------------------------------------------
--SELECT * FROM 
------------------------------------------------------------------------------------

go