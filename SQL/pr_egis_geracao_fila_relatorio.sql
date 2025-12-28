--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_geracao_fila_relatorio' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_geracao_fila_relatorio

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_geracao_fila_relatorio
-------------------------------------------------------------------------------
--pr_egis_geracao_fila_relatorio
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
--                   Notícias e Eventos
--
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_geracao_fila_relatorio
@json nvarchar(max) = ''

--with encryption


as

--drop table AleJson
--select * from AleJson
--select cast(@json as nvarchar(max))  as ale into AleJson
--select 'ok' as msg

--set @json = isnull(@json,'')

--set @json = isnull(@json,'')

--select @json


SET NOCOUNT ON;

-- 1) NÃO destrua o JSON
-- REMOVA qualquer linha como:
-- SET @json = REPLACE(@json, '\', '');

-- 2) Se vier como "string de JSON": "...."
--select @json

set @json = replace(
             replace(
               replace(
                replace(
                  replace(
                    replace(
                      replace(
                        replace(
                          replace(
                            replace(
                              replace(
                                replace(
                                  replace(
                                    replace(
                                    @json, CHAR(13), ' '),
                                  CHAR(10),' '),
                                ' ',' '),
                              ':\\\"',':\\"'),
                            '\\\";','\\";'),
                          ':\\"',':\\\"'),
                        '\\";','\\\";'),
                      '\\"','\"'),
                    '\"', '"'),
                  '',''),
                '["','['),
              '"[','['),
             ']"',']'),
          '"]',']') 

-- 4) Validação

IF ISJSON(@json) <> 1
BEGIN
    THROW 50001, 'JSON inválido em @json.', 1;
    RETURN;
END


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

-----------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    

set @cd_parametro = ISNULL(@cd_parametro,0)

------------------------------------------------------------
  -- (B) QUEBRA EM HEADER/ITENS
  ------------------------------------------------------------
  ;WITH j AS (
    SELECT CONVERT(int, JSON_VALUE(js.value, '$.cd_empresa'))                     AS cd_empresa,
           ISNULL(JSON_VALUE(js.value, '$.nm_banco_empresa'), '')                 AS nm_banco_empresa,
           ISNULL(JSON_VALUE(js.value, '$.nm_fila'), 'RELATORIOS')                AS nm_fila,
           CONVERT(int, JSON_VALUE(js.value, '$.cd_modulo'))                      AS cd_modulo,
           CONVERT(int, JSON_VALUE(js.value, '$.cd_etapa'))                       AS cd_etapa,
           CONVERT(int, JSON_VALUE(js.value, '$.cd_relatorio'))                   AS cd_relatorio,
           CONVERT(int, JSON_VALUE(js.value, '$.cd_status_relatorio'))            AS cd_status_relatorio,
           CONVERT(int, JSON_VALUE(js.value, '$.cd_usuario_relatorio'))           AS cd_usuario_relatorio,
           CONVERT(int, JSON_VALUE(js.value, '$.cd_usuario'))                     AS cd_usuario,
           ISNULL(JSON_VALUE(js.value, '$.observacao'), '')                       AS ds_ocorrencia,
           JSON_QUERY(js.value, '$.composicoes')                                  AS composicoes
    FROM OPENJSON(@json) js
  )

  SELECT *
  INTO #header
  FROM j;

-- Itens (um explode por header)
  SELECT
      identity(int,1,1)                                                  as id,
      isnull(h.cd_empresa,@cd_empresa)                                   as cd_empresa,
      h.cd_modulo,
      h.cd_etapa,
      h.cd_relatorio,
      h.cd_usuario,
      h.cd_usuario_relatorio,
      h.cd_status_relatorio,
      h.ds_ocorrencia,
      CONVERT(int, JSON_VALUE(i.value, '$.cd_documento'))       AS cd_documento,
      CONVERT(int, JSON_VALUE(i.value, '$.cd_item_documento'))  AS cd_item_documento,
      CONVERT(int, JSON_VALUE(i.value, '$.cd_ordem_impressao')) AS cd_ordem_impressao
  INTO #itens
  FROM #header h
  CROSS APPLY OPENJSON(h.composicoes) i;

  --select * from #header
  --select * from #itens

  ------------------------------------------------------------
  -- (C) INSERTS EM TRANSAÇÃO
  ------------------------------------------------------------
  BEGIN TRY
    BEGIN TRAN;

    DECLARE @cd_fila            INT = 0
    declare @cd_fila_composicao int = 0
    
    select 
      @cd_fila = max(cd_fila)
    from
      Fila_Servico_Relatorio

    set @cd_fila = isnull(@cd_fila,0) + 1

    INSERT INTO Fila_Servico_Relatorio
      (cd_fila, nm_fila, cd_modulo, cd_etapa, cd_usuario_relatorio, cd_relatorio,
       cd_status_relatorio, ds_ocorrencia, cd_usuario, dt_usuario_inclusao, cd_usuario_inclusao,
       qt_documento, cd_ordem)
    SELECT
      @cd_fila,h.nm_fila, h.cd_modulo, h.cd_etapa, h.cd_usuario_relatorio, h.cd_relatorio,
      h.cd_status_relatorio, h.ds_ocorrencia, h.cd_usuario, GETDATE(), h.cd_usuario,
      0 /* ajustado abaixo */, NULL
    FROM #header h;

    --SET @cd_fila = SCOPE_IDENTITY();


    select @cd_fila_composicao = max(cd_fila_composicao)
    from
      Fila_Servico_Relatorio_Composicao

    set @cd_fila_composicao = isnull(@cd_fila_composicao,0) + 1

    INSERT INTO Fila_Servico_Relatorio_Composicao
      (cd_fila_composicao, cd_fila, cd_documento, cd_item_documento,
       cd_usuario, dt_usuario_inclusao, cd_ordem_impressao)
    SELECT
      @cd_fila_composicao + id, @cd_fila, i.cd_documento, ISNULL(i.cd_item_documento,0),
      i.cd_usuario, GETDATE(), ISNULL(i.cd_ordem_impressao,1)
    FROM #itens i;

    --select * from #itens

    DECLARE @qtd INT = @@ROWCOUNT;

    UPDATE Fila_Servico_Relatorio
       SET qt_documento = @qtd
     WHERE cd_fila = @cd_fila;

    COMMIT;

    SELECT
      'ENFILEIRADO'        AS status,
      @cd_fila             AS cd_fila,
      @qtd                 AS qt_documento,
      MIN(i.cd_documento)  AS menor_documento,
      MAX(i.cd_documento)  AS maior_documento
    FROM #itens i;

  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
  END CATCH



GO





GO

--use egissql_354
go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_geracao_fila_relatorio 
------------------------------------------------------------------------------
go
--use egissql_354
--select * from Fila_Servico_Relatorio_PrintLog
--select * from Fila_Servico_Relatorio_Saida
--select * from Fila_Servico_Relatorio
--select * from Fila_Servico_Relatorio_Composicao
/*
delete from Fila_Servico_Relatorio_PrintLog
delete from Fila_Servico_Relatorio_Saida
delete from Fila_Servico_Relatorio_Composicao
delete from Fila_Servico_Relatorio
*/

go
EXEC pr_egis_geracao_fila_relatorio 
    @json = N'[
      {
        "cd_modulo": 282,
        "cd_etapa": 1,
        "cd_usuario_relatorio": 123,
        "cd_relatorio": 11,
        "cd_status_relatorio": 1,
        "ds_ocorrencia": "Teste inclusão fila",
        "cd_usuario": 123,
        "cd_usuario_inclusao": 123,
        "qt_documento": 10,
        "cd_ordem": 1,
        "composicoes": [
            { "cd_documento": 94, "cd_item_documento": 1, "cd_ordem_impressao": 1 },
            { "cd_documento": 93, "cd_item_documento": 1, "cd_ordem_impressao": 2 },
            { "cd_documento": 97, "cd_item_documento": 1, "cd_ordem_impressao": 2 }
        ]
      }
    ]'
go
--select * from Fila_Servico_Relatorio
--
--select * from Fila_Servico_Relatorio

--fila
--Tabelas : Fila_Servico_Relatorio
--select * from Fila_Servico_Relatorio
--#cd_fila int   (chave)
--nm_fila  varchar(500) = ''
--cd_modulo int
--cd_etapa  int
--cd_usuario_relatorio int
--cd_relatorio int
--cd_status_relatorio int
--ds_ocorrencia text
--cd_usuario int
--dt_usuario int
--cd_usuario_inclusao int
--dt_usuario_inclusao int
--qt_documento int
--cd_ordem     int

--Fila_Servico_Relatorio_Composicao
--select * from Fila_Servico_Relatorio_Composicao

--#cd_fila_composicao int
--E cd_fila int
--E cd_documento int
--E cd_item_documento int
--cd_usuario int
--dt_usuario int
--cd_usuario_inclusao int
--dt_usuario_inclusao int
--cd_ordem_impressao int

--Status_Fila_Relatorio

--#cd_status_relatorio int
--nm_status_relatorio varchar(80)
--..
--c)Atualizar a Tabela de Fila - Status do Relatório ( 1-Aguardando 2-Imprimindo 3-Ocorrência 4-Impresso )


IF OBJECT_ID('dbo.Fila_Servico_Relatorio_Saida','U') IS NULL
BEGIN
  CREATE TABLE dbo.Fila_Servico_Relatorio_Saida(
      cd_fila_arquivo     INT IDENTITY(1,1) PRIMARY KEY,
      cd_fila             INT           NOT NULL,
      cd_documento        INT           NULL,
      cd_item_documento   INT           NULL,
      nm_arquivo          NVARCHAR(260) NULL,
      ds_html             NVARCHAR(MAX) NULL,
      dt_inclusao         DATETIME      NOT NULL DEFAULT(GETDATE())
  );
  CREATE INDEX IX_Saida_Fila ON dbo.Fila_Servico_Relatorio_Saida(cd_fila);
END
GO
use egissql_354
go