IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_consulta_nota_sem_protocolo_nfe' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_consulta_nota_sem_protocolo_nfe

GO

-------------------------------------------------------------------------------
--sp_helptext pr_consulta_nota_sem_protocolo_nfe
-------------------------------------------------------------------------------
--pr_consulta_nota_sem_protocolo_nfe
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2010
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : Egissql
--
--Objetivo         : Consulta de Notas Fiscais sem Protocolo NFE
--Data             : 14.02.2010
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_consulta_nota_sem_protocolo_nfe
@dt_inicial datetime = '',
@dt_final   datetime


as


select
  ns.cd_nota_saida,
  ns.cd_identificacao_nota_saida,
  ns.dt_nota_saida,
  ns.cd_mascara_operacao,
  ns.vl_total,
  ns.nm_fantasia_nota_saida,
  u.nm_fantasia_usuario
from
  nota_saida ns
  left outer join egisadmin.dbo.usuario u on u.cd_usuario = ns.cd_usuario

where
  ns.dt_nota_saida between @dt_inicial and @dt_final

order by
  ns.dt_nota_saida

 
--select * from nota_saida


go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_consulta_nota_sem_protocolo_nfe '01/01/2000','12/31/2011'
------------------------------------------------------------------------------
