IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_chave_nota_entrada_devolucao' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_chave_nota_entrada_devolucao
GO

CREATE VIEW vw_nfe_chave_nota_entrada_devolucao    
------------------------------------------------------------------------------------    
--sp_helptext vw_nfe_chave_nota_entrada_devolucao    
------------------------------------------------------------------------------------    
--GBS - Global Business Solution                                        2026    
------------------------------------------------------------------------------------    
--Stored Procedure : Microsoft SQL Server 2016    
--Autor(es)          : Fagner Cardoso
--Banco de Dados    : EGISSQL     
--    
--Objetivo          : Chave de acesso referencia Nota Entrada
--Data              : 09.01.2026    
--Atualização       :
-----------------------------------------------------------------------------------------------------------------  
as
select
   ns.cd_nota_saida,
   ne.cd_nota_entrada,
   ne.cd_operacao_fiscal,
   ne.cd_fornecedor,
   ne.cd_serie_nota_fiscal,
   nc.cd_chave_acesso,
   max(est.cd_ibge_estado) as 'cUF',
   substring(cast(datepart(yyyy,max(ne.dt_nota_entrada)) as varchar(4)),3,2) +
   dbo.fn_strzero(datepart(mm,max(ne.dt_nota_entrada)),2) as 'AAMM',
   max(vw.cd_cnpj) as 'CNPJ',
   isnull(max(sn.cd_modelo_serie_nota),'55') as 'mod',
   dbo.fn_strzero(ltrim(rtrim(cast(isnull(max(sn.qt_serie_nota_fiscal),0) as varchar(3)))),3) as 'serie',
   -- dbo.fn_strzero(max(ne.cd_nota_entrada),9) as 'nNF' --Número da Nota Fiscal
   cast(max(ne.cd_nota_entrada) as varchar(9)) as nNF

from
  nota_saida_item i
  inner join nota_saida ns on ns.cd_nota_saida = i.cd_nota_saida
  inner join nota_entrada ne on case when isnull(ne.cd_destinatario_faturamento,0)>0 
                                                            then ne.cd_destinatario_faturamento
                                                            else ne.cd_fornecedor end = ns.cd_cliente and
                                                            ne.cd_nota_entrada = i.cd_nota_entrada
  inner join nota_entrada_item nei on nei.cd_nota_entrada = ne.cd_nota_entrada and
                                                            nei.cd_fornecedor = ne.cd_fornecedor and
                                                            nei.cd_operacao_fiscal = ne.cd_operacao_fiscal and
                                                            nei.cd_serie_nota_fiscal = ne.cd_serie_nota_fiscal and
                                                            isnull(nei.cd_produto,0) = isnull(i.cd_produto,0)
  inner join nota_entrada_complemento nc on nc.cd_nota_entrada = ne.cd_nota_entrada and
                                                            nc.cd_fornecedor = ne.cd_fornecedor and
                                                            nc.cd_operacao_fiscal = ne.cd_operacao_fiscal and
                                                            nc.cd_serie_nota_fiscal = ne.cd_serie_nota_fiscal
  inner join vw_destinatario vw on vw.cd_destinatario = case when isnull(ne.cd_destinatario_faturamento,0)>0 
                                                                                             then ne.cd_destinatario_faturamento 
                                                                                             else ne.cd_fornecedor end and
                                                            vw.cd_tipo_destinatario = case when isnull(ne.cd_tipo_destinatario_fatura,0)>0 
                                                                                                            then ne.cd_tipo_destinatario_fatura 
                                                                                                            else ne.cd_tipo_destinatario end
  left outer join serie_nota_fiscal sn on sn.cd_serie_nota_fiscal = ne.cd_serie_nota_fiscal
  left outer join Estado est with (nolock) on est.cd_estado = vw.cd_estado

where
  isnull(i.cd_nota_entrada,0)<>0

group by
  ns.cd_nota_saida,
  ne.cd_nota_entrada,
  ne.cd_operacao_fiscal,
  ne.cd_fornecedor,
  ne.cd_serie_nota_fiscal,
  nc.cd_chave_acesso

go

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select * from vw_nfe_chave_nota_entrada_devolucao where cd_nota_saida = 90425
------------------------------------------------------------------------------------