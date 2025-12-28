--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_geracao_retorno_banco' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_geracao_retorno_banco

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_geracao_retorno_banco
-------------------------------------------------------------------------------
--pr_egis_geracao_retorno_banco
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Egis
--                   Geração de Retorno de Banco
--
--Data             : 03.09.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_geracao_retorno_banco
@json nvarchar(max) = ''

--with encryption


as

SET NOCOUNT ON;

--select @json

--set @json = replace(
--             replace(
--               replace(
--                replace(
--                  replace(
--                    replace(
--                      replace(
--                        replace(
--                          replace(
--                            replace(
--                              replace(
--                                replace(
--                                  replace(
--                                    replace(
--                                    @json, CHAR(13), ' '),
--                                  CHAR(10),' '),
--                                ' ',' '),
--                              ':\\\"',':\\"'),
--                            '\\\";','\\";'),
--                          ':\\"',':\\\"'),
--                        '\\";','\\\";'),
--                      '\\"','\"'),
--                    '\"', '"'),
--                  '',''),
--                '["','['),
--              '"[','['),
--             ']"',']'),
--          '"]',']') 

-- 4) Validação


--IF ISJSON(@json) <> 1
--BEGIN
--    THROW 50001, 'JSON inválido em @json.', 1;
--    RETURN;
--END


declare @cd_empresa          int
declare @cd_parametro        int = 0
declare @cd_documento        int = 0
declare @cd_item_documento   int
declare @cd_usuario          int 
declare @dt_hoje             datetime
declare @dt_inicial          datetime 
declare @dt_final            datetime
declare @cd_ano              int = 0
declare @cd_mes              int = 0
declare @cd_conta_banco      int = 0
declare @cd_portador         int = 0
declare @dados_arquivo       nvarchar(max) = ''

----------------------------------------------------------------------------------------------------------------

set @cd_empresa        = 0
set @cd_parametro      = 0
set @cd_documento      = 0
set @cd_item_documento = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano = year(getdate())
set @cd_mes = month(getdate())  

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end


--tabela
--select ic_sap_admin, * from Tabela where cd_tabela = 5287

select                     

 1                                                    as id_registro,
 IDENTITY(int,1,1)                                    as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]                                      as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

--select * from #json

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_documento           = valor from #json where campo = 'cd_documento'
select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_conta_banco         = valor from #json where campo = 'cd_conta_banco'
select @dados_arquivo          = valor from #json where campo = 'dados_arquivo'
-----------------------------------------------------------------------------------------
--IF @cd_conta_banco IS NULL OR @cd_conta_banco = 0
--   THROW 50002, 'Informe cd_conta_banco no JSON.', 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_empresa   = dbo.fn_empresa()
set @cd_parametro = ISNULL(@cd_parametro,0)

if isnull(@cd_parametro,0) = 1
begin
  select
   c.*,
   b.nm_fantasia_banco,
   d.nm_mascara_arquivo,
   d.nm_local_arquivo,
   d.nm_extensao_arquivo

  from
    conta_agencia_banco c
    inner join banco b                       on b.cd_banco = c.cd_banco  
    left outer join Documento_Arquivo_Magnetico d on d.cd_documento_magnetico = c.cd_documento_retorno
  where
     isnull(c.cd_documento_magnetico,0)>0
  
  order by
    c.nm_conta_banco
    return
end

select @dados_arquivo as dados_arquivo, '<- Arquivo TXT que foi inputado pelo usuário' as Msg

--use egissql_354
go------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_geracao_retorno_banco 
------------------------------------------------------------------------------
go

go
EXEC pr_egis_geracao_retorno_banco 
'[
{
    "cd_parametro": "1"
}
]'

--EXEC pr_egis_geracao_retorno_banco 
--'[
--{
--    "dados_arquivo": "01REMESSA01COBRANCA       724300990103        FLASH PINTURAS TECNICAS LTDA. 341BANCO ITAU SA  080925                                                                                                                                                                                                                                                                                                      000001\r\n10234447251000130724300990103        337114                   00005000            0109                     I01337114          1910250000000347231341     01N08092500000000000000000000000000000000000000000000000000000000000000BIGUA DISTRIBUIDORA DE SOM E AAV ANTENOR DE ALMEIDA, 1282             JARDIM COLON7047590 BAURU          SP                                                               000002\r\n9                                                                                                                                                                                                                                                                                                                                                                                                         000003\r\n",
--    "cd_usuario": "4890",
--    "cd_empresa": "357"
--}
--]'

go
