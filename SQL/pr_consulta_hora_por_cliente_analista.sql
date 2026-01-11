------------------------------------------------------------------------
--pr_consulta_hora_por_cliente_analista
------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                 2004
------------------------------------------------------------------------
--Stored Procedure      : Microsoft SQL Server 2000
--Autor(es)             : Johnny
--Banco de Dados        : EGISSQL
--Objetivo              : Consultar horas de visitas por cliente e analista
--Data                  : 20/03/04
--Atualizado            : 27/12/2004 - Acerto do Cabeçalho - Sérgio Cardoso
---------------------------------------------------------------------------


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_consulta_hora_por_cliente_analista' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_consulta_hora_por_cliente_analista
GO

CREATE PROCEDURE pr_consulta_hora_por_cliente_analista
@dt_inicial 			datetime,
@dt_final 			datetime
AS

  select
    c.nm_fantasia_cliente		as Cliente,
    a.nm_fantasia_analista		as Analista,

    --Cálculo das horas realizadas
    cast(sum(datediff(n,convert(DateTime, osai.nm_hora_inicio_ordem), 
                   convert(DateTime, osai.nm_hora_fim_ordem)))/60.00 as decimal(15,2))as HorasRealizadas

  from
    Ordem_Servico_Analista 	osa  left outer join
    Ordem_Servico_Analista_Item osai on osa.cd_ordem_servico = osai.cd_ordem_servico left outer join
    Cliente 			c    on osa.cd_cliente = c.cd_cliente left outer join
    Analista			a    on osa.cd_analista = a.cd_analista
  where
    osa.dt_ordem_servico between @dt_inicial and @dt_final
  group by
    c.nm_fantasia_cliente,
    a.nm_fantasia_analista
  order by
    1 asc, 3 desc

GO
-- =============================================
-- Testando a procedure
-- =============================================
--EXECUTE pr_consulta_hora_por_cliente_analista '02/01/04', '02/29/04'
-----------------------------------------------------------------------------------------
GO