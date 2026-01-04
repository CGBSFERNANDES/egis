IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_veiculos_nota_fiscal' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_veiculos_nota_fiscal
GO

CREATE VIEW vw_nfe_veiculos_nota_fiscal
------------------------------------------------------------------------------------
--sp_helptext vw_nfe_veiculos_nota_fiscal
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2004
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSQL 
--
--Objetivo	        : Identificação do Local da Retirada da Nota Fiscal 
--                        para o sistema de emissão da Nota Fiscal Eletrônica
--
--Data                  : 05.11.2008
--Atualização           : 27.09.2010 - Ajuste para novo lay-out v2.00 - Carlos Fernandes
------------------------------------------------------------------------------------
as


select
  'J'                                                            as 'veicProd',
  '' as tpOp,
  '' as chassi,
  '' as cCor,
  '' as xCor,
  '' as pot,
  '' as cilin,
  '' as PesoL,
  '' as PesoB,
  '' as nSerie,
  '' as tpComb,
  '' as nMotor,
  '' as CMT,
  '' as dist,
  '' as anoMod,
  '' as anoFab,
  '' as tpPint,
  '' as tpVeic,
  '' as espVeic,
  '' as VIN,
  '' as codVeic,
  '' as cMod,
  '' as cCorDenatram,
  '' as lota,
  '' as tpRest
	
  


go

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_nfe_veiculos_nota_fiscal
------------------------------------------------------------------------------------

go