CREATE PROCEDURE pr_renomear_arquivo_certificado
  @json NVARCHAR(MAX)
AS
BEGIN
  DECLARE @url NVARCHAR(4000), @novoNome NVARCHAR(200), @cmd NVARCHAR(4000)

  SELECT 
    @url = JSON_VALUE(@json, '$[0].url'),
    @novoNome = JSON_VALUE(@json, '$[0].novoNome')

  -- Caminho local esperado no servidor
  SET @cmd = 'RENAME ' + 
             'D:\CAMINHO\DO\UPLOAD\' + 
             PARSENAME(REPLACE(@url, '/', '.'), 1) + 
             ' ' + @novoNome

  -- EXEC master..xp_cmdshell @cmd
  -- Apenas log (ajuste para rodar)
  SELECT @cmd AS comando;
END
