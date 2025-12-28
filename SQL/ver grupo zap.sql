CREATE TABLE Whatsapp_Grupo (
    nm_grupo   VARCHAR(200),
    chatId     VARCHAR(100)
);

INSERT INTO Whatsapp_Grupo (nm_grupo, chatId)
VALUES ('GBS - Dynamix (Gestão)', '120363012345678901-1234567890@g.us');


DECLARE @chatId VARCHAR(100);

SELECT @chatId = chatId
FROM Whatsapp_Grupo
WHERE nm_grupo = @nm_documento;  -- aqui você pode passar o nome do grupo

-- E na montagem do JSON:
SET @BODY = '{
  "chatId": "' + @chatId + '",
  "contentType": "string",
  "content": "'+ LTRIM(RTRIM(@ds_parametro)) + '"
}';
