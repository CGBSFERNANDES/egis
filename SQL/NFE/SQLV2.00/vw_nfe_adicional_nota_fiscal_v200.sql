IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_adicional_nota_fiscal'
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_adicional_nota_fiscal
GO

CREATE VIEW vw_nfe_adicional_nota_fiscal
------------------------------------------------------------------------------------
--sp_helptext vw_nfe_adicional_nota_fiscal
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2004
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSQL 
--
--Objetivo	        : Informações Adicionais da Nota Fiscal 
--                        para o sistema de emissão da Nota Fiscal Eletrônica
--
--Data                  : 06.11.2008
--Atualização           : 24.11.2008
-- 27.09.2010 - Ajuste para novo lay-out v2.00 - Carlos Fernandes
-- 15.02.2017 - Código de Barra EAN - Carlos Fernandes
-- 05.02.2024 - Novo Campo para Adicional do Contribuinte - Pedro Jardim
-- 06.01.2026 - Ajustes nos campos infCpl e infCpf - Denis Rabello
------------------------------------------------------------------------------------
as

--select * from nota_saida_item
--select * from nota_saida
--select * from nota_saida_parcela

select
  ns.cd_identificacao_nota_saida,
  ns.cd_nota_saida,
  'Z01'                                                          as 'infAdic',
  cast('' as varchar(2000))                                      as 'infAdFisco',
  --cast('' as varchar(5000))                                    as 'infCpf',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,1,250)   as varchar(500))))   as 'infCpl', 
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,1,250)   as varchar(500))))   as 'infCpf',
  --cast(ns.ds_obs_compl_nota_saida as varchar(5000))              as 'infCpf',  
  'Z04'                                                          as 'obsCont',
  cast('' as varchar(20))                                        as 'xCampo',
  cast('' as varchar(60))                                        as 'xTexto',
  cast('' as varchar)                                            as 'obsFisco',
  'Z10'                                                          as 'procRef',
  cast('' as varchar(60))                                        as 'nProc',
  --Não tem no Egis
  0                                                              as 'indProc',  --> 0 : SEFAZ,

  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,1,250)    as varchar(250))))   as 'infCpf1',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,251,250)  as varchar(250))))   as 'infCpf2',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,501,250)  as varchar(250))))   as 'infCpf3',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,751,250)  as varchar(250))))   as 'infCpf4',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,1001,250) as varchar(250))))   as 'infCpf5',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,1251,250) as varchar(250))))   as 'infCpf6',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,1501,250) as varchar(250))))   as 'infCpf7',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,1751,250) as varchar(250))))   as 'infCpf8',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,2001,250) as varchar(250))))   as 'infCpf9',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,2251,250) as varchar(250))))   as 'infCpf10',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,2501,250) as varchar(250))))   as 'infCpf11',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,2751,250) as varchar(250))))   as 'infCpf12',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,3001,250) as varchar(250))))   as 'infCpf13',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,3251,250) as varchar(250))))   as 'infCpf14',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,3501,250) as varchar(250))))   as 'infCpf15',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,3751,250) as varchar(250))))   as 'infCpf16',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,4001,250) as varchar(250))))   as 'infCpf17',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,4251,250) as varchar(250))))   as 'infCpf18',
  ltrim(rtrim(cast(substring(ns.ds_obs_compl_nota_saida,4751,250) as varchar(250))))   as 'infCpf19',

  ' '+
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,1,250)    as varchar(250))))   as 'infCpf20',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,251,250)  as varchar(250))))   as 'infCpf21',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,501,250)  as varchar(250))))   as 'infCpf22',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,751,250)  as varchar(250))))   as 'infCpf23',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,1001,250) as varchar(250))))   as 'infCpf24',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,1251,250) as varchar(250))))   as 'infCpf25',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,1501,250) as varchar(250))))   as 'infCpf26',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,1751,250) as varchar(250))))   as 'infCpf27',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,2001,250) as varchar(250))))   as 'infCpf28',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,2251,250) as varchar(250))))   as 'infCpf29',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,2501,250) as varchar(250))))   as 'infCpf30',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,2751,250) as varchar(250))))   as 'infCpf31',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,3001,250) as varchar(250))))   as 'infCpf32',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,3251,250) as varchar(250))))   as 'infCpf33',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,3501,250) as varchar(250))))   as 'infCpf34',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,3751,250) as varchar(250))))   as 'infCpf35',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,4001,250) as varchar(250))))   as 'infCpf36',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,4251,250) as varchar(250))))   as 'infCpf37',
  ltrim(rtrim(cast(substring(ns.ds_obs_usuario_nota_saida,4751,250) as varchar(250))))   as 'infCpf38',

  --Divisao dos Dados Adicionais-------------------------------------------------------------------------------
  
  -- Dados Adicionais para o Contribuinte
  isnull(cp.cd_identificacao_fornecedor,'')                                              as cd_identificacao_fornecedor
  

from
  nota_saida ns                           with (nolock)
  left outer join cliente c               with (nolock) on c.cd_cliente  = ns.cd_cliente
  left outer join cliente_parametro cp    with (nolock) on cp.cd_cliente = c.cd_cliente

go

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_nfe_adicional_nota_fiscal
------------------------------------------------------------------------------------

go