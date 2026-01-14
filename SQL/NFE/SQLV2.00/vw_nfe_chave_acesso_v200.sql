IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_chave_acesso' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_chave_acesso
GO

CREATE VIEW vw_nfe_chave_acesso

------------------------------------------------------------------------------------
--sp_helptext vw_nfe_chave_acesso
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2004
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSQL 
--Objetivo	        : Geração do Arquivo Texto para Importar o Cadastro da Empresa
--                        para o sistema de emissão da Nota Fiscal Eletrônica
--Data                  : 04.11.2008
--Atualização           : 28.09.2009 - Série da Nota - Carlos Fernandes
-- 23.09.2010 - forma de emissão da nfe no código de acesso - Carlos Fernandes
-- 27.09.2010 - Ajuste para novo lay-out v2.00 - Carlos Fernandes
-- 18.11.2011 - Verificação da composição da chave - não foi modificado nada somente para teste - Marcelo
-- 29.04.2014 - Mudança com dados de Acordo com a Série da Nota - Carlos Fernandes
-- 01.03.2016 - foi colocada na view a série da nota - Carlos Fenrandes
-- 02.09.2019 - Acerto, do campo cNF nova Validação da Receita - Fagner Cardoso
-- 06.07.2021 - Inclusão da Empresa Faturamento --Fagner Cardoso
------------------------------------------------------------------------------------
as

--select * from egisadmin.dbo.empresa
--select * from estado

select
  e.cd_empresa,
  ns.cd_identificacao_nota_saida,
  ns.cd_serie_nota,
  ns.dt_nota_saida,
  ns.cd_nota_saida,
  ns.sg_estado_nota_saida                               as 'UF',
  est.cd_ibge_estado                                    as 'cUF',
  substring(cast(datepart(yyyy,ns.dt_nota_saida) as varchar(4)),3,2) + 
  dbo.fn_strzero(datepart(mm,ns.dt_nota_saida),2)       as 'AAMM',
  case when isnull(snf.cd_empresa_selecao,0)<>0 then
     ef.cd_cnpj_empresa
  else
     e.cd_cgc_empresa
  end                                                   as 'CNPJ',

--  case when isnull(snf.cd_modelo_serie_nota,'')<>'' then snf.cd_modelo_serie_nota else '55' end as 'mod',

--  '55'                                                  as 'mod',

--  dbo.fn_strzero(isnull(snf.qt_serie_nota_fiscal,0),3)  as 'serie',

  case when isnull(ns.cd_modelo_serie_nota,'')<>'' and 
                   ns.cd_modelo_serie_nota <> snf.cd_modelo_serie_nota 
  then isnull(ns.cd_modelo_serie_nota,'55') else isnull(snf.cd_modelo_serie_nota,'55') end      as 'mod',


  dbo.fn_strzero(case when ns.qt_serie_nota_fiscal = 0 then
    ltrim(rtrim(cast(isnull(ns.qt_serie_nota_fiscal,0) as varchar(3))))
  else
    ltrim(rtrim(cast(isnull(snf.qt_serie_nota_fiscal,0) as varchar(3))))
  end,3)                                                                                        as 'serie',

  dbo.fn_strzero(ns.cd_identificacao_nota_saida,9)      as 'nNF', --Número da Nota Fiscal

  --forma de emissão--------------------------------------------------
  dbo.fn_strzero(v.cd_forma_emissao_nfe,1)              as 'femi',   

  dbo.fn_strzero(ns.cd_nota_saida,8)                    as 'cNF',
-- Nova quantidade de dígitos

 -- dbo.fn_strzero(ns.cd_identificacao_nota_saida,8)      as 'cNF', --Número Aleatório para Nota Fiscal
 
  dbo.fn_digito_modulo_11(
     cast( isnull(est.cd_ibge_estado,'35')           as varchar(2))    +
     substring(cast(datepart(yyyy,ns.dt_nota_saida)  as varchar(4)),3,2) + 
     dbo.fn_strzero(datepart(mm,ns.dt_nota_saida),2)                    +
     cast(case when isnull(snf.cd_empresa_selecao,0)<>0 then
             ef.cd_cnpj_empresa
          else
             e.cd_cgc_empresa
          end              as varchar(14))      +

--Antes de 28.9.2009
--     '55'                                                   +
--     dbo.fn_strzero( isnull(snf.qt_serie_nota_fiscal,0),3 ) + 

--     case when isnull(snf.cd_modelo_serie_nota,'')<>'' then snf.cd_modelo_serie_nota else '55' end

     case when isnull(ns.cd_modelo_serie_nota,'')<>'' and 
                      ns.cd_modelo_serie_nota <> snf.cd_modelo_serie_nota 
     then isnull(ns.cd_modelo_serie_nota,'55') else isnull(snf.cd_modelo_serie_nota,'55') end
     +

     dbo.fn_strzero(case when ns.qt_serie_nota_fiscal = 0 then
       ltrim(rtrim(cast(isnull(ns.qt_serie_nota_fiscal,0) as varchar(3))))
     else
       ltrim(rtrim(cast(isnull(snf.qt_serie_nota_fiscal,0) as varchar(3))))
     end,3)                             +

     dbo.fn_strzero(ns.cd_identificacao_nota_saida,9) +
     dbo.fn_strzero(v.cd_forma_emissao_nfe,1) +
 --   dbo.fn_strzero(ns.cd_identificacao_nota_saida,8) 
     dbo.fn_strzero(ns.cd_nota_saida,8)       ,43)            as 'cDV',

  --Chave de Acesso

     'NFe' +
     cast(isnull(est.cd_ibge_estado,35)           as varchar(2))    +
     substring(cast(datepart(yyyy,ns.dt_nota_saida) as varchar(4)),3,2) + 
     dbo.fn_strzero(datepart(mm,ns.dt_nota_saida),2)                    +
     cast(case when isnull(snf.cd_empresa_selecao,0)<>0 then
             ef.cd_cnpj_empresa
          else
             e.cd_cgc_empresa
          end              as varchar(14))      +

--Antes de 28.9.2009
--     '55'                                                   +
--     dbo.fn_strzero( isnull(snf.qt_serie_nota_fiscal,0),3 ) + 

--     case when isnull(snf.cd_modelo_serie_nota,'')<>'' then snf.cd_modelo_serie_nota else '55' end
     case when isnull(ns.cd_modelo_serie_nota,'')<>'' and 
                      ns.cd_modelo_serie_nota <> snf.cd_modelo_serie_nota 
     then isnull(ns.cd_modelo_serie_nota,'55') else isnull(snf.cd_modelo_serie_nota,'55') end

     +

     dbo.fn_strzero(case when ns.qt_serie_nota_fiscal = 0 then
       ltrim(rtrim(cast(isnull(ns.qt_serie_nota_fiscal,0) as varchar(3))))
     else
       ltrim(rtrim(cast(isnull(snf.qt_serie_nota_fiscal,0) as varchar(3))))
     end,3)                                   +

     dbo.fn_strzero(ns.cd_identificacao_nota_saida,9)       +
     dbo.fn_strzero(v.cd_forma_emissao_nfe,1) +
     --dbo.fn_strzero(ns.cd_identificacao_nota_saida,8)       +
     dbo.fn_strzero(ns.cd_nota_saida,8)       +

     --Dígito

     dbo.fn_digito_modulo_11(
     cast( est.cd_ibge_estado           as varchar(2))                  +
     substring(cast(datepart(yyyy,ns.dt_nota_saida) as varchar(4)),3,2) + 
     dbo.fn_strzero(datepart(mm,ns.dt_nota_saida),2)                    +
     cast(case when isnull(snf.cd_empresa_selecao,0)<>0 then
             ef.cd_cnpj_empresa
          else
             e.cd_cgc_empresa
          end              as varchar(14))                  +

--Antes de 28.9.2009
--     '55'                                                   +
--     dbo.fn_strzero( isnull(snf.qt_serie_nota_fiscal,0),3 ) + 

--     case when isnull(snf.cd_modelo_serie_nota,'')<>'' then snf.cd_modelo_serie_nota else '55' end

     case when isnull(ns.cd_modelo_serie_nota,'')<>'' and 
                      ns.cd_modelo_serie_nota <> snf.cd_modelo_serie_nota 
     then isnull(ns.cd_modelo_serie_nota,'55') else isnull(snf.cd_modelo_serie_nota,'55') end

     +

     dbo.fn_strzero(case when ns.qt_serie_nota_fiscal = 0 then
       ltrim(rtrim(cast(isnull(ns.qt_serie_nota_fiscal,0) as varchar(3))))
     else
       ltrim(rtrim(cast(isnull(snf.qt_serie_nota_fiscal,0) as varchar(3))))
     end,3)                             +

     dbo.fn_strzero(ns.cd_identificacao_nota_saida,9) +
     dbo.fn_strzero(v.cd_forma_emissao_nfe,1) + 
--     dbo.fn_strzero(ns.cd_identificacao_nota_saida,8),43)             as 'ChaveAcesso'
     dbo.fn_strzero(ns.cd_nota_saida,8),43)             as 'ChaveAcesso'
     /*
     case when ns.cd_finalidade_nfe = 2 then
     dbo.fn_strzero(nfr.cd_nota_referencia,8)
     else      
     dbo.fn_strzero(ns.cd_identificacao_nota_saida,8)
     end
      ,43)             as 'ChaveAcesso'
     */
    

--select * from serie_nota_fiscal
  
from
  nota_saida ns                           with (nolock) 
  left outer join serie_nota_fiscal snf   with (nolock) on snf.cd_serie_nota_fiscal = ns.cd_serie_nota
  left outer join egisadmin.dbo.empresa e with (nolock) on e.cd_empresa             = case when isnull(snf.cd_empresa,0)<>0
                                                                                      then snf.cd_empresa
                                                                                      else
                                                                                        dbo.fn_empresa() 
                                                                                      end
  left outer join Empresa_Faturamento ef   with (nolock) on ef.cd_empresa           = snf.cd_empresa_selecao
  left outer join cnae  c                  with (nolock) on c.cd_cnae               = e.cd_cnae
  left outer join Pais  p                  with (nolock) on p.cd_pais               = case when isnull(snf.cd_empresa_selecao,0) <>0 then
                                                                                         ef.cd_pais
																					  else                                                                                        
																						 e.cd_pais
																					  end
  left outer join Estado est               with (nolock) on est.cd_estado           = case when isnull(snf.cd_empresa_selecao,0) <>0 then
                                                                                         ef.cd_estado
																					  else                                                                                        
																						 e.cd_estado
																					  end
  left outer join Cidade cid               with (nolock) on cid.cd_estado           = case when isnull(snf.cd_empresa_selecao,0) <>0 then
                                                                                         ef.cd_estado
																					  else                                                                                        
																						 e.cd_estado
																					  end and
                                                            cid.cd_cidade           = case when isnull(snf.cd_empresa_selecao,0) <>0 then
                                                                                         ef.cd_cidade
																					  else                                                                                        
																						 e.cd_cidade
																					  end
  left outer join versao_nfe  v           with (nolock) on v.cd_empresa             = e.cd_empresa
--  left outer join Nota_Saida_Referenciada nfr with (nolock) on nfr.cd_nota_saida = ns.cd_nota_saida 

--where
--  isnull(ns.ic_nfe_nota_saida,'N') = 'N'
  

--select * from cnae
--select * from versao_nfe

go

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select ChaveAcesso, * from vw_nfe_chave_acesso where cd_nota_saida =  88679
------------------------------------------------------------------------------------

--select * from nota_saida_referenciada where cd_nota_saida =  90037455
go