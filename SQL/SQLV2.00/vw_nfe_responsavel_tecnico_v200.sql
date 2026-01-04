IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_responsavel_tecnico' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_responsavel_tecnico
GO

CREATE VIEW vw_nfe_responsavel_tecnico
------------------------------------------------------------------------------------
--sp_helptext vw_nfe_responsavel_tecnico
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                              2021
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)         : Pedro Jardim
--Banco de Dados	  : EGISSQL 
--
--Objetivo	        : Exibe os Dados do Responsável Técnico do Software Emissor
--
--Data                  : 22.07.2021
--Atualização           : 11.08.2025 - Atualizar !!!!
------------------------------------------------------------------------------------

as

select
  top 1
  '16875807000108'                    as CNPJ,
  'GBS TECNOLOGIA E CONSULTORIA LTDA' as xContato,
  'financeiro@gbstec.com.br'          as email,
  '39074141'                          as fone


go

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_nfe_responsavel_tecnico
------------------------------------------------------------------------------------


go