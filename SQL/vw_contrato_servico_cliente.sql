IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_contrato_servico_cliente' 
	   AND 	  type = 'V')
    DROP VIEW vw_contrato_servico_cliente
GO

CREATE VIEW vw_contrato_servico_cliente
------------------------------------------------------------------------------------
--sp_helptext vw_contrato_servico_cliente
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2012
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSQL 
--
--Objetivo	        : Consulta do Contrato de Serviço por cliente
--
--Data                  : 05.09.2012
--Atualização           : 
--
------------------------------------------------------------------------------------
as
 
--select * from contrato_servico
--ordem_servico_analista_item

select
  cs.cd_cliente,
  cs.cd_contrato_servico,
  cs.cd_ref_contrato_servico               as Referencia,
  isnull(cs.vl_contrato_servico,0)         as vl_contrato_servico,
  isnull(cs.qt_parc_contrato_servico,0)    as qt_parc_contrato_servico,
  isnull(cs.vl_parcela_contrato_servico,0) as vl_parcela_contrato_servico,
  isnull(cs.vl_hora_contrato_servico,0)    as vl_hora_contrato_servico,
  
  s.nm_servico,
  cs.dt_final_contrato_servico,

  --Dados do Cliente--

  c.nm_fantasia_cliente,
  c.nm_razao_social_cliente,
  c.cd_cnpj_cliente,
  c.nm_endereco_cliente,
  c.cd_numero_endereco,
  c.nm_complemento_endereco,
  c.nm_bairro,
  c.cd_cep,
  cid.nm_cidade,
  est.sg_estado,

  v.cd_vendedor,
  v.nm_vendedor

from
  contrato_servico cs        with (nolock)
  left outer join servico s  with (nolock) on s.cd_servico  = cs.cd_servico
  left outer join cliente c  with (nolock) on c.cd_cliente  = cs.cd_cliente
  left outer join estado est with (nolock) on est.cd_estado = c.cd_estado
  left outer join cidade cid with (nolock) on cid.cd_cidade = c.cd_cidade 
  left outer join vendedor v with (nolock) on v.cd_vendedor = c.cd_vendedor

  
go

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_contrato_servico_cliente
------------------------------------------------------------------------------------

go