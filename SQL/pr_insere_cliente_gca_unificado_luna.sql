IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_insere_cliente_gca_unificado' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_insere_cliente_gca_unificado
GO

---------------------------------------------------------------------
-- sp_helptext pr_insere_cliente_gca_unificado 
--------------------------------------------------------------------- 
--GBS - Global Business Solution Ltda                            2022 
---------------------------------------------------------------------
--Stored Procedure    : Microsoft SQL Server 2000 
--Autor(es)           : Fabiano Vinco Zanqueta
--Banco de Dados      : EGISSQL 
--Objetivo            : Objetivo.... 
--Data                : 30/05/2022 
--Atualizado          : 
------------------------------------------------------------------------------------------------------ 
CREATE PROCEDURE pr_insere_cliente_gca_unificado 
@cd_parametro          int = 0,
@nm_fantasia_cliente   varchar(60) = '',
@cd_cnpj_cliente       varchar(18) = '',
@cd_ddd_cliente        varchar(4)  = '',
@cd_celular_cliente    varchar(15) = '',
@nm_email_cliente      varchar(150) = '',
@dt_nascimento_cliente datetime = '',
@cd_usuario            int = 0

AS 

set dateformat mdy

if @cd_parametro = 0 or @cd_parametro is null
  set @cd_parametro = 0

declare @Tabela varchar(80)
declare @cd_cliente int

if @cd_parametro = 0 
begin
  set @Tabela = cast('EGISSQL_360.dbo.Cliente' as varchar(80))          
  set @cd_cliente = 0          

  exec sp_PegaCodigoDB @Tabela, 'cd_cliente', 0, @cd_usuario, @cd_cliente out;   

  Insert Into EGISSQL_360.dbo.Cliente   
  (cd_cliente, nm_fantasia_cliente, nm_razao_social_cliente,  
   ic_destinacao_cliente, dt_cadastro_cliente, cd_tipo_pessoa,                
   cd_cnpj_cliente, cd_ramo_atividade, cd_status_cliente,                
   cd_transportadora, cd_tipo_mercado, cd_idioma, cd_usuario,                
   dt_usuario, ic_liberado_pesq_credito, cd_ddd, cd_telefone,
   cd_ddd_celular_cliente, cd_celular_cliente,
   nm_email_cliente, dt_aniversario_cliente)  
   Values  
  (@cd_cliente, @nm_fantasia_cliente, @nm_fantasia_cliente,  
   '1', GETDATE(), 2, @cd_cnpj_cliente, 1, 1, 1, 1, 1, 
   @cd_usuario, GETDATE(), 'S',  
   @cd_ddd_cliente, @cd_celular_cliente,
   @cd_ddd_cliente, @cd_celular_cliente,
   @nm_email_cliente, @dt_nascimento_cliente)

  Insert Into EGISSQL_371.dbo.Cliente
  Select * from EGISSQL_360.dbo.Cliente where cd_cliente = @cd_cliente

  --Insert Into EGISSQL_372.dbo.Cliente
  --Select * from EGISSQL_360.dbo.Cliente where cd_cliente = @cd_cliente

  --Insert Into EGISSQL_373.dbo.Cliente
  --Select * from EGISSQL_360.dbo.Cliente where cd_cliente = @cd_cliente

  exec sp_LiberaCodigoDB @Tabela, 'cd_cliente', @cd_cliente, 0, 'D'
end

go

------------------------------------------------------------------------------
--Testando a Stored Procedure
/*----------------------------------------------------------------------------
exec pr_insere_cliente_gca_unificado 0

@cd_parametro = 0
----------------------------------------------------------------------------*/