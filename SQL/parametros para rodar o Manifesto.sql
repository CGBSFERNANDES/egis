
/*
use egissql_363
--return

delete from dfe_cursor

-- 1) logs e comandos
TRUNCATE TABLE DFe_Log;
TRUNCATE TABLE DFe_Manifesto_Log;
TRUNCATE TABLE DFe_Comandos;

-- 2) inbox (documentos)
TRUNCATE TABLE DFe_Inbox;

-- 3) cursor (controle)
TRUNCATE TABLE DFe_Cursor;

DELETE FROM DFe_Manifesto_Log;
DELETE FROM DFe_Comandos;
DELETE FROM DFe_Log;
DELETE FROM DFe_Inbox;
DELETE FROM DFe_Cursor;


SELECT DB_NAME() AS banco_atual;

SELECT * FROM DFe_Cursor;
SELECT COUNT(*) AS inbox_qtd FROM DFe_Inbox;
SELECT TOP 10 * FROM DFe_Log ORDER BY 1 DESC;            -- ajuste coluna/PK
SELECT TOP 20 * FROM DFe_Manifesto_Log ORDER BY 1 DESC;  -- idem
SELECT TOP 20 * FROM DFe_Comandos ORDER BY 1 DESC;       -- idem


SELECT COUNT(*) AS cursor_qtd FROM DFe_Cursor;
SELECT COUNT(*) AS inbox_qtd  FROM DFe_Inbox;

select * from dfe_cursor
select * from dfe_inbox
select * from DFe_log
select * from DFe_Manifesto_Log
select * from DFe_Comandos
select * from DFe_Sync_Log


*/

