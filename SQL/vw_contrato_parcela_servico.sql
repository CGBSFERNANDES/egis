IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_contrato_parcela_servico' 
	   AND 	  type = 'V')
    DROP VIEW vw_contrato_parcela_servico
GO

CREATE VIEW vw_contrato_parcela_servico
------------------------------------------------------------------------------------
--sp_helptext vw_contrato_parcela_servico
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                              2019
------------------------------------------------------------------------------------
--Stored Procedure   : Microsoft SQL Server 2000 / 2008 / 2012 / 2014 / 2016
--
--Autor(es)          : Carlos Cardoso Fernandes
--
--Banco de Dados     : EGISSQL 
--
--Objetivo           : Consulta das Parcelas dos Contratos de Empreendimento
--
--
--Data               : 22.12.2018
--Atualização        : 
--
------------------------------------------------------------------------------------
as
 


select

  cs.* ,


  dr.cd_identificacao,
  dr.cd_documento_receber,
  isnull(dr.vl_documento_receber,0)                                         as vl_documento_receber,
  drp.dt_pagamento_documento                                                as dt_pagamento,

  isnull(drp.vl_pagamento_documento,0.00)                                   as vl_pagamento,

  cast(
  case when
     (cs.dt_parc_contrato_servico < convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121) or dr.dt_vencimento_documento<convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121))
       and isnull(drp.vl_pagamento_documento,0) = 0 then
      cs.vl_parc_contrato_servico 
  else
     0.00
  end as decimal(25,2))                                                      as vl_atraso,
  convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)  as dt_hoje,
  isnull(c.cd_servico,0)                                                     as cd_servico,
  s.nm_servico                                                               as nm_empreendimento,
  cli.nm_razao_social_cliente                                                as nm_cliente,
  v.nm_fantasia_vendedor                                                     as nm_fantasia_vendedor,
  isnull(c.vl_hora_contrato_servico,0)                                       as vl_total_contrato,
  c.cd_status_contrato
  



from
  Contrato_Servico_Composicao cs

  inner join contrato_servico c                   on c.cd_contrato_servico    = cs.cd_contrato_servico

  left outer join documento_receber dr            on dr.cd_contrato           = c.cd_contrato_servico and 
                                                     dr.cd_parcela_nota_saida = cs.cd_item_contrato_servico

  left outer join documento_receber_pagamento drp on drp.cd_documento_receber = dr.cd_documento_receber
  left outer join servico s                       on s.cd_servico             = c.cd_servico
  left outer join cliente cli                     on cli.cd_cliente           = c.cd_cliente
  left outer join vendedor v                      on v.cd_vendedor            = c.cd_vendedor

where
  isnull(c.cd_status_contrato,1) = 1 --Ativo
  and
  c.dt_cancelamento_contrato is null


go

--select * from status_contrato
--select cd_parcela_nota_saida,* from documento_receber where cd_contrato = 51

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_contrato_parcela_servico where cd_contrato_servico = 333

------------------------------------------------------------------------------------
go
--select cd_parcela_nota_saida,* from documento_receber where cd_contrato = 51
go