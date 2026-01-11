IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_parcela_contrato_servico' 
	   AND 	  type = 'V')
    DROP VIEW vw_parcela_contrato_servico
GO

CREATE VIEW vw_parcela_contrato_servico
------------------------------------------------------------------------------------
--sp_helptext vw_parcela_contrato_servico
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2017
------------------------------------------------------------------------------------
--Stored Procedure   : Microsoft SQL Server 2000 / 2008 / 2012 / 2014 / 2016
--
--Autor(es)          : Carlos Cardoso Fernandes
--Banco de Dados     : EGISSQL 
--
--Objetivo           : Parcelas do Contrato de Serviço
--
--Data               : 02.11.2017
--Atualização        : 
--
------------------------------------------------------------------------------------
as
 
select
  cs.cd_contrato_servico,
  cs.dt_parc_contrato_servico                                       as dt_parcela,
  sum(cast(isnull(cs.vl_parc_contrato_servico,0) as decimal(25,2))) as vl_parcela,
  sum(cast( 
 
  round(isnull(cs.vl_parc_contrato_servico,0)
  -
  --Ir
  (case when isnull(c.ic_retencao_ir_contrato,'N') = 'N' then
    0.00
  else
    case when ( isnull(c.pc_ir_retencao_contrato,0) / 100 ) * isnull(cs.vl_parc_contrato_servico,0) >=10 then
      (isnull(c.pc_ir_retencao_contrato,0) / 100 ) * isnull(cs.vl_parc_contrato_servico,0)
    else
      0.00
    end
  end) 
  -
  --Iss
  (case when isnull(c.ic_retencao_iss_contrato,'N') = 'N' then
    0.00
  else
   (isnull(c.pc_iss_retencao_contrato,0) / 100 ) * isnull(cs.vl_parc_contrato_servico,0)
  end)                                                           
  ,2) as decimal(25,2)))                                                               as vl_liquido_parcela



from

  Contrato_Servico_Composicao cs       with (nolock)
  inner join contrato_servico c        with (nolock) on c.cd_contrato_servico = cs.cd_contrato_servico
  inner join cliente cl                with (nolock) on cl.cd_cliente         = c.cd_cliente
  left outer join status_contrato sc   with (nolock) on sc.cd_status_contrato   = c.cd_status_contrato
  left outer join status_cliente stc   with (nolock) on stc.cd_status_cliente   = cl.cd_status_cliente

where
  isnull(sc.ic_controle_contrato,'S')='S'
  and isnull(stc.ic_operacao_status_cliente,'N')='S'
  
group by
  cs.cd_contrato_servico,
  cs.dt_parc_contrato_servico

--  cs.dt_parc_contrato_servico between @dt_inicial and @dt_final



go


------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_parcela_contrato_servico
------------------------------------------------------------------------------------

go