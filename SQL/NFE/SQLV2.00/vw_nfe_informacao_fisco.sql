IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_informacao_fisco' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_informacao_fisco
GO

CREATE VIEW vw_nfe_informacao_fisco
------------------------------------------------------------------------------------
--sp_helptext vw_nfe_informacao_fisco
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                            2021
------------------------------------------------------------------------------------
--Stored Procedure	 : Microsoft SQL Server 2000
--Autor(es)          : Carlos Cardoso Fernandes
--Banco de Dados	 : EGISSQL 
--
--Objetivo	         : Informações do Fiscal da Nota Fiscal
--Data               : 10.06.2021
--Atualização       
-----------------------------------------------------------------------------------------------------------------
as



--declare @dt_hoje as datetime
--set @dt_hoje    = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)

select
  ns.cd_identificacao_nota_saida,
  ns.cd_nota_saida,
  ns.dt_nota_saida,
  cast(f.ds_informacao_fisco as varchar(2000))    as infAdFisco_Z02
    
from
  nota_saida ns                                 with (nolock) 
  inner join nota_saida_informacao_fisco f      with (nolock) on f.cd_nota_saida = ns.cd_nota_saida

where
  cast(f.ds_informacao_fisco as varchar(2000))<>''
go

--select * from vw_nfe_chave_acesso

--select cd_tipo_operacao_fiscal,* from nota_saida

--select top 1000 * from vw_nfe_chave_acesso

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_nfe_informacao_fisco where cd_identificacao_nota_saida = 09519352
--09519352

------------------------------------------------------------------------------------

go