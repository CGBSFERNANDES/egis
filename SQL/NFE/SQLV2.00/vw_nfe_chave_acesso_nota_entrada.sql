IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_chave_acesso_nota_entrada' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_chave_acesso_nota_entrada
GO

CREATE VIEW vw_nfe_chave_acesso_nota_entrada
------------------------------------------------------------------------------------
--sp_helptext vw_nfe_chave_acesso
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2004
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSQL 
--Objetivo	        : View que mostra chave de acesso de nota de entrada
--                        Recebimento
--                        
--Data                  : 09.03.2011
--Atualização           : 
------------------------------------------------------------------------------------
as

--select * from egisadmin.dbo.empresa
--select * from estado
--select * from vw_destinatario

select
  ne.cd_nota_entrada,
  ne.cd_fornecedor,
  ne.cd_operacao_fiscal,
  ne.cd_serie_nota_fiscal,
  nc.cd_chave_acesso,
  est.cd_ibge_estado                                    as 'cUF',
  
  substring(cast(datepart(yyyy,ne.dt_nota_entrada) as varchar(4)),3,2) + 
  dbo.fn_strzero(datepart(mm,ne.dt_nota_entrada),2)       as 'AAMM',
  vw.cd_cnpj                                              as 'CNPJ',

  isnull(sn.cd_modelo_serie_nota,'55')                    as 'mod',


  dbo.fn_strzero(ltrim(rtrim(cast(isnull(sn.qt_serie_nota_fiscal,0) as varchar(3))))
  ,3)                                                      as 'serie',

  dbo.fn_strzero(ne.cd_nota_entrada,9)      as 'nNF' --Número da Nota Fiscal


from
  nota_entrada ne
  inner join nota_entrada_complemento nc on nc.cd_nota_entrada      = ne.cd_nota_entrada     and
                                            nc.cd_fornecedor        = ne.cd_fornecedor       and
                                            nc.cd_operacao_fiscal   = ne.cd_operacao_fiscal  and
                                            nc.cd_serie_nota_fiscal = ne.cd_serie_nota_fiscal 
  inner join vw_destinatario vw          on vw.cd_destinatario      = ne.cd_fornecedor       and
                                            vw.cd_tipo_destinatario = ne.cd_tipo_destinatario

  left outer join serie_nota_fiscal sn   on sn.cd_serie_nota_fiscal = ne.cd_serie_nota_fiscal

  left outer join Estado est              with (nolock) on est.cd_estado            = vw.cd_estado

--select * from nota_entrada_complemento

go

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_nfe_chave_acesso_nota_entrada
------------------------------------------------------------------------------------

go