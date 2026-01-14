IF EXISTS (SELECT * 
	   FROM   sysobjects 
	   WHERE  name = N'fn_hora_HHMMSS_NFE')
	DROP FUNCTION fn_hora_HHMMSS_NFE
GO

---------------------------------------------------------------------------------------
--fn_hora_HHMMSS_NFE
---------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                          2014
---------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)	  	      : Carlos Cardoso Fernandes
--Banco de Dados	   : EGISSQL ou EGISADMIN
--Objetivo		      : 
--
--Data			      : 01.01.2014
--Atualização        : 
---------------------------------------------------------------------------------------

create FUNCTION fn_hora_HHMMSS_NFE

(@dt_formato    datetime  )

returns char(8)

as

begin

  declare @s char(8)

  set @s = dbo.fn_strzero(datepart(hh,@dt_formato),2) + ':' + 
           dbo.fn_strzero(datepart(mi,@dt_formato),2) + ':' + 
           dbo.fn_strzero(datepart(ss,@dt_formato),2) 

  return @s

end

GO

---------------------------------------------------------------------------------------
-- Example to execute function
---------------------------------------------------------------------------------------
--SELECT dbo.fn_hora_HHMMSS_NFE( getdate() ) as Hora
---------------------------------------------------------------------------------------

GO

