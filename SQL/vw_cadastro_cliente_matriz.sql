IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_cadastro_cliente_matriz' 
	   AND 	  type = 'V')
    DROP VIEW vw_cadastro_cliente_matriz
GO

---------------------------------------------------------------------
-- sp_helptext vw_cadastro_cliente_matriz 
--------------------------------------------------------------------- 
--GBS - Global Business Solution Ltda                            2022 
---------------------------------------------------------------------
--Stored VIEW    : Microsoft SQL Server 2000 
--Autor(es)           : Fabiano Vinco Zanqueta
--Banco de Dados      : EGISSQL 
--Objetivo            : Objetivo.... 
--Data                : 30/05/2022 
--Atualizado          : 
------------------------------------------------------------------------------------------------------ 
CREATE VIEW vw_cadastro_cliente_matriz 

AS 

select
  *
from
  Cliente

go

------------------------------------------------------------------------------
--Testando a VIEW
/*----------------------------------------------------------------------------
select * from vw_cadastro_cliente_matriz
----------------------------------------------------------------------------*/