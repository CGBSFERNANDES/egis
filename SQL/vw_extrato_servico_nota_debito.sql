IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_extrato_servico_nota_debito' 
	   AND 	  type = 'V')
    DROP VIEW vw_extrato_servico_nota_debito
GO

CREATE VIEW vw_extrato_servico_nota_debito
------------------------------------------------------------------------------------
--sp_helptext vw_extrato_servico_nota_debito
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2012
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSQL 
--
--Objetivo	        : Nota de Débito por Ordem de Serviço
--
--Data                  : 06.09.2012
--Atualização           : 
--
------------------------------------------------------------------------------------
as

--select * from ordem_servico_analista_despesa

select
  o.cd_ordem_servico,
  d.cd_nota_debito_despesa, 
  sum( isnull(nd.vl_nota_debito,0))  as vl_nota_debito

  
from
  ordem_servico_analista o
  inner join ordem_servico_analista_despesa d on d.cd_ordem_servico        = o.cd_ordem_servico
  inner join nota_debito_despesa nd           on nd.cd_nota_debito_despesa = d.cd_nota_debito_despesa

where
  isnull(d.cd_nota_debito_despesa,0)>0

group by
  o.cd_ordem_servico,
  d.cd_nota_debito_despesa
 
go

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_extrato_servico_nota_debito
------------------------------------------------------------------------------------

go