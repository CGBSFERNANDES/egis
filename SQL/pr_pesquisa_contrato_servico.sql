IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_pesquisa_contrato_servico' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_pesquisa_contrato_servico

GO

-------------------------------------------------------------------------------
--sp_helptext pr_pesquisa_contrato_servico
-------------------------------------------------------------------------------
--pr_pesquisa_contrato_servico
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2021
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : Egissql - Banco do Cliente
--
--Objetivo         : pesquisa de contratos por cliente
--Data             : 01.01.2021
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_pesquisa_contrato_servico
@cd_cliente int = 0

--with encryption


as  


set @cd_cliente = isnull(@cd_cliente,0)

--select * from status_contrato

select 
  cs.cd_contrato_servico                                                  as cd_controle,               --Controle
  cs.cd_contrato_servico,                                                                               --Contrato
  cs.dt_contrato_servico,                                                                               --Emissão
  cs.ds_contrato                                                             as ds_informativo,         --Descritivo
  cs.dt_ini_contrato_servico,          --Início
  cs.dt_final_contrato_servico,        --Fim
  day(cs.dt_vct1p_contrato_servico) ,  --Dia Vencimento,
  cs.vl_parcela_contrato_servico,
  cs.dt_base_reajuste_contrato,
  ir.nm_indice_reajuste,
  nm_contrato_pdf = 'http://egisnet.com.br/pdf/c'+cast(cs.cd_contrato_servico as varchar(06)) + '.pdf', --Arquivo
  nm_proposta_pdf = 'http://egisnet.com.br/pdf/p'+cast(cs.cd_contrato_servico as varchar(06)) + '.pdf'  --Proposta
from
  contrato_servico cs
  
  left outer join indice_reajuste ir          on ir.cd_indice_reajuste = cs.cd_indice_reajuste
where
  cs.cd_cliente = @cd_cliente
  and
  isnull(cs.cd_status_contrato,1) = 1
  --and

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_pesquisa_contrato_servico 65
------------------------------------------------------------------------------
