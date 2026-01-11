IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_consulta_cont_serv_reajuste' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_consulta_cont_serv_reajuste
GO

------------------------------------------------------------------ 
--pr_consulta_cont_serv_reajuste
------------------------------------------------------------------
--GBS - Global Business Solution Ltda       	             2004
------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server       2000
--Autor(es)		: Daniel C. Neto.
--Banco de Dados	: EGISSQL
--Objetivo		: Consultar Contratos de Serviço para Reajuste de Valores.
--Data			: 06/04/2004
--Atualização           : 27/12/2004 - Acerto do Cabeçalho - Sérgio Cardoso
------------------------------------------------------------------------------------

CREATE PROCEDURE pr_consulta_cont_serv_reajuste

@cd_servico           int,
@dt_inicial           datetime,
@dt_final             datetime

AS

SELECT     
  cs.cd_ref_contrato_servico, 
  sc.nm_status_contrato, 
  c.nm_fantasia_cliente, 
  cs.dt_contrato_servico, 
  cs.vl_contrato_servico,  
  cs.dt_base_reajuste_contrato, 
  tr.nm_tipo_reajuste, 
  s.nm_servico,
  cast(cs.dt_contrato_servico -  (GetDate()-1) as int) as 'Atraso',    
  cs.dt_ini_contrato_servico,
  cs.dt_final_contrato_servico,
  ( select max(x.dt_reajuste_contrato) 
    from Contrato_Servico_Reajuste x
    where x.cd_contrato_servico = cs.cd_contrato_servico ) as 'dt_ultimo_reajuste'


FROM         
  Contrato_Servico cs left outer join
  Status_Contrato sc ON cs.cd_status_contrato = sc.cd_status_contrato left outer join
  Cliente c ON cs.cd_cliente = c.cd_cliente left outer join
  Tipo_Reajuste tr on tr.cd_tipo_reajuste = cs.cd_tipo_reajuste left outer join
  Servico s ON cs.cd_servico = s.cd_servico
where
   cs.dt_contrato_servico between @dt_inicial and @dt_final and
   ( cs.cd_servico = @cd_servico or
     @cd_servico = 0 )
   



go
---------------------------------------------------------------
--Testando a Stored Procedure
---------------------------------------------------------------
--exec pr_consulta_cont_serv_reajuste
--@cd_servico           = 0,
--@dt_inicial           = '01/01/2004',
--@dt_final             = '06/01/2004'


--select cd_usuario from Requisicao_Compra where cd_requisicao_compra = 301


-- 
-- select top 100 * from requisicao_compra where year(dt_emissao_req_compra ) = 2003
-- select cd_departamento, cd_usuario,* from requisicao_compra where cd_requisicao_compra = 83564
-- 
-- select * from egisadmin..usuario where cd_usuario = 106
--sp_helptext pr_consulta_requisicao_compra
