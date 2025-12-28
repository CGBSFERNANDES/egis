--delete from Nota_Emitida_Empresa
--delete from dfe_cursor

use EGISADMIN
    SELECT *
    FROM NFe_Empresa
    WHERE isnull(ic_ativo,'N')='S' and isnull(ic_dfe_ativo,'S')='S' 
    ORDER BY cd_cnpj_empresa     


select * from DFe_Comandos
select * from DFe_Cursor
select * from DFe_Inbox
select * from DFe_Manifesto_Log


SELECT chave_nfe, tipo, schema_xml, LEN(CAST(xml_conteudo AS NVARCHAR(MAX))) lenxml
FROM DFe_Inbox
WHERE chave_nfe = '29250803045773000182550010000014991983224432';

SELECT TOP (50) chave_nfe
FROM DFe_Inbox WITH (READPAST)
WHERE tipo = 'resumo'
  AND (xml_conteudo IS NULL OR schema_xml IS NULL)
ORDER BY recebido_em ASC;


--SELECT COUNT(*) pendentes
--FROM DFe_Inbox
--WHERE tipo='resumo' AND (xml_conteudo IS NULL OR schema_xml IS NULL);


--DECLARE @res int;
--EXEC @res = sp_getapplock
--     @Resource = CONCAT('dfe:', @cnpjBase),
--     @LockMode = 'Exclusive',
--     @LockOwner = 'Session',
--     @LockTimeout = 0;

--IF @res < 0
--BEGIN
--  -- já tem alguém processando esse CNPJ; apenas saia
--  SELECT 1/0; -- opcional: force erro para o caller desistir
--  RETURN;
--END

---- ... chamada SEFAZ ...

--EXEC sp_releaseapplock
--     @Resource = CONCAT('dfe:', @cnpjBase),
--     @LockOwner = 'Session';



     --

     USE EGISSQL_354
     GO
     DELETE FROM DFe_Comandos
     DECLARE @cnpj NVARCHAR(14) = '27677562000120'; -- seu CNPJ

DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
SELECT i.chave_nfe
FROM EGISADMIN.dbo.DFe_Inbox i
WHERE i.tipo='resumo'
  AND (i.xml_conteudo IS NULL OR i.schema_xml IS NULL);

OPEN cur;
DECLARE @chave NVARCHAR(44);
DECLARE @XJON  NVARCHAR(MAX);
SET @XJON = N'{"tipo":"ciencia","cnpj":"'+@cnpj+'"}';
FETCH NEXT FROM cur INTO @chave;
WHILE @@FETCH_STATUS = 0
BEGIN
  EXEC dbo.pr_api_distdfe_manifesto
       @cd_parametro = 25,
       @chave        = @chave,
       @json         = @XJON
  FETCH NEXT FROM cur INTO @chave;
END
CLOSE cur; DEALLOCATE cur;
USE EGISADMIN
GO

SET IDENTITY_INSERT DFe_Comandos ON;
INSERT INTO DFe_Comandos
SELECT 

tipo,
payload,
status,
saida,
criado_em,
processado_em
FROM EGISSQL_354.DBO.DFe_Comandos
SET IDENTITY_INSERT DFe_Comandos OFF;