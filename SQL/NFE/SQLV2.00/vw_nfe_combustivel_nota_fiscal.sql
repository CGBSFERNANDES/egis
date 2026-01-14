IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_combustivel_nota_fiscal' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_combustivel_nota_fiscal
GO

CREATE VIEW vw_nfe_combustivel_nota_fiscal
------------------------------------------------------------------------------------
--sp_helptext vw_nfe_combustivel_nota_fiscal
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2004
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSQL 
--
--Objetivo	        : Combustível
--                        para o sistema de emissão da Nota Fiscal Eletrônica
--
--Data                  : 25.09.2014
--Atualização           : 
------------------------------------------------------------------------------------

as  
  
  
select
  i.cd_nota_saida,
  i.cd_item_nota_saida,
  n.cd_identificacao_nota_saida,

  --
  isnull(cf.cd_anp_classificacao,'')         as cProdANP,

  --UFCONS
  n.sg_estado_nota_saida                     as UFCONS


  
from
  nota_saida_item i
  inner join nota_saida n            on n.cd_nota_saida            = i.cd_nota_saida
  inner join classificacao_fiscal cf on cf.cd_classificacao_fiscal = i.cd_classificacao_fiscal



  
go


------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_nfe_combustivel_nota_fiscal where cd_identificacao_nota_saida = 9519368
-----------------------------------------------------------------------------------

go