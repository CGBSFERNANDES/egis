IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_conta_agencia_banco' 
	   AND 	  type = 'V')
    DROP VIEW vw_conta_agencia_banco
GO

CREATE VIEW vw_conta_agencia_banco
---------------------------------------------------------------------------------------
--sp_helptext vw_conta_agencia_banco
---------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                              2021
---------------------------------------------------------------------------------------
--Stored Procedure   : Microsoft SQL Server 2000 / 2008 / 2012 / 2014 / 2016
--
--Autor(es)          : Carlos Cardoso Fernandes
--Banco de Dados     : EGISSQL ou EGISADMIN
--
--Objetivo           : Descrição do que a View Realiza
--
--Data               : 01.01.2019
--Atualização        : 
--
--------------------------------------------------------------------------------------
as
 

select
  LTRIM(RTRIM(ag.cd_numero_agencia_banco))+'/'+cab.nm_conta_banco+'-'+cab.cd_dac_conta_banco as Conta,
  cab.cd_conta_banco,
  cab.nm_conta_banco,
  isnull(cab.cd_dac_conta_banco,'') as cd_dac_conta_banco,
  cab.cd_banco,
  cab.cd_agencia_banco,
  b.cd_numero_banco,
  ag.nm_agencia_banco,
  cab.cd_beneficiario_conta

 from
   Conta_Agencia_Banco cab
   left outer join Agencia_Banco ag on ag.cd_agencia_banco = cab.cd_agencia_banco
   left outer join Banco b          on b.cd_banco          = cab.cd_banco

 where
  isnull(cab.ic_cobranca_eletronica,'N')='S'



go


------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_conta_agencia_banco
------------------------------------------------------------------------------------

go