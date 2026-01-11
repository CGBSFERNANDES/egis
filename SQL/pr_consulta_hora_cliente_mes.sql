--------------------------------------------------------------------------
--pr_consulta_hora_cliente_mes
--------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                   2004
--------------------------------------------------------------------------
--Stored Procedure       : Microsoft SQL Server 2000
--Autor(es)              : Johnny
--Banco de Dados         : EGISSQL
--Objetivo               : Consultar horas de visitas por cliente e mes
--Data                   : 20/03/04
--Atualizado             : 27/12/2004 - Acerto do Cabeçalho - Sérgio Cardoso
------------------------------------------------------------------------------
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_consulta_hora_cliente_mes' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_consulta_hora_cliente_mes
GO

CREATE PROCEDURE pr_consulta_hora_cliente_mes
@dt_inicial 			datetime,
@dt_final 			datetime
AS

  select
    c.nm_fantasia_cliente		as Cliente,
    year(osa.dt_ordem_servico)		as Ano,
    month(osa.dt_ordem_servico)		as Mes,
    --Cálculo das horas realizadas
    cast(sum(datediff(n,convert(DateTime, osai.nm_hora_inicio_ordem), 
                   convert(DateTime, osai.nm_hora_fim_ordem)))/60.00 as decimal(15,2))as HorasRealizadas

  from
    Ordem_Servico_Analista 	osa  left outer join
    Ordem_Servico_Analista_Item osai on osa.cd_ordem_servico = osai.cd_ordem_servico left outer join
    Cliente 			c    on osa.cd_cliente = c.cd_cliente
  group by
    c.nm_fantasia_cliente,
    year(osa.dt_ordem_servico),
    month(osa.dt_ordem_servico)
  order by
    1,2,3

GO
-- =============================================
-- Testando a procedure
-- =============================================
--EXECUTE pr_consulta_hora_cliente_mes '01/01/04', '03/31/04'
-----------------------------------------------------------------------------------------
GO