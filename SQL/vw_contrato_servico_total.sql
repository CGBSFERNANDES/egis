IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_contrato_servico_total' 
	   AND 	  type = 'V')
    DROP VIEW vw_contrato_servico_total
GO

CREATE VIEW vw_contrato_servico_total
------------------------------------------------------------------------------------
--sp_helptext vw_contrato_servico_total
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2012
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSQL 
--
--Objetivo	        : Total de Contrato de Serviço por cliente
--
--Data                  : 07.09.2012
--Atualização           : 
--
------------------------------------------------------------------------------------
as
 
--select * from contrato_servico
--ordem_servico_analista_item


select
  os.cd_contrato_servico, 
  max(cs.cd_ref_contrato_servico)            as Referencia,
  max(isnull(cs.vl_contrato_servico,0))      as vl_contrato_servico,
  max(isnull(cs.qt_parc_contrato_servico,0)) as qt_parc_contrato_servico,
  max(isnull(cs.vl_hora_contrato_servico,0)) as vl_hora_contrato_servico,
  max(cs.dt_final_contrato_servico)          as dt_final_contrato_servico,

 --TOTAL DE HORAS------------------------------------------------------------------------
 sum( round( (
               (cast(datepart(hh, cast(os.qt_total_normal_ordem as DATETIME))as float)+(cast(datepart(mi, cast(os.qt_total_normal_ordem as DATETIME)) as float) /60)) +  
               (cast(datepart(hh, cast(os.qt_total_extra_ordem as DATETIME))as float)+(cast(datepart(mi, cast(os.qt_total_extra_ordem as DATETIME)) as float) /60)) 


  ),0)) as Horas_total,
  max( cs.qt_hora_contrato_servico ) - 
   sum( round( (
               (cast(datepart(hh, cast(os.qt_total_normal_ordem as DATETIME))as float)+(cast(datepart(mi, cast(os.qt_total_normal_ordem as DATETIME)) as float) /60)) +  
               (cast(datepart(hh, cast(os.qt_total_extra_ordem as DATETIME))as float)+(cast(datepart(mi, cast(os.qt_total_extra_ordem as DATETIME)) as float) /60)) 


  ),0))  as Saldo_Total

from
  Ordem_Servico_Analista_Item i        with (nolock) 
  inner join Ordem_Servico_Analista os on os.cd_ordem_servico = i.cd_ordem_servico
  inner join Contrato_Servico cs       on cs.cd_contrato_servico = os.cd_contrato_servico

where
  isnull(os.cd_contrato_servico,0)<>0

group by
  os.cd_contrato_servico

  
go

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_contrato_servico_total
------------------------------------------------------------------------------------

go