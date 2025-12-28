CREATE OR ALTER PROCEDURE pr_egis_processa_fila_relatorio
  @json NVARCHAR(MAX) = ''
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE
    @cd_parametro        INT,
    @cd_fila             INT,
    @quem                SYSNAME = SUSER_SNAME(),
    @erros               INT = 0,
    @ok                  INT = 0;

  ------------------------------------------------------------
  -- 1) Ler parâmetros do JSON
  ------------------------------------------------------------
  -- Esperado (exemplo):
  -- [
  --   { "ic_json_parametro":"S", "cd_parametro":1, "cd_fila": 123 }
  -- ]
  SELECT
    @cd_parametro = TRY_CAST(JSON_VALUE(j.value,'$.cd_parametro') AS INT),
    @cd_fila      = TRY_CAST(JSON_VALUE(j.value,'$.cd_fila')      AS INT)
  FROM OPENJSON(@json) AS j;

  IF ISNULL(@cd_parametro,1) = 1 AND @cd_fila IS NULL
  BEGIN
    RAISERROR('Parâmetro inválido: informe cd_fila no JSON.', 16, 1);
    RETURN;
  END

  IF isnull(@cd_fila,0) = 0 -- IS NULL
  BEGIN
    RAISERROR('Parâmetro inválido: informe cd_fila.',16,1); RETURN;
  END


  ------------------------------------------------------------
  -- 2) Trava a fila e marca "em processamento"
  ------------------------------------------------------------
  ;WITH alvo AS (
    SELECT TOP (1) *
    FROM Fila_Servico_Relatorio WITH (ROWLOCK, UPDLOCK, READPAST)
    WHERE cd_fila = @cd_fila
  )
  UPDATE alvo
     SET cd_status_relatorio = 2,      -- 2=Processando
         dt_usuario           = GETDATE(),
         ds_ocorrencia        = CONCAT(ISNULL(ds_ocorrencia,''), ' [', CONVERT(varchar(19),GETDATE(),120), '] start por ', @quem)
  ;

  IF @@ROWCOUNT = 0
  BEGIN
    RAISERROR('Fila %d não encontrada.', 16, 1, @cd_fila);
    RETURN;
  END

  ------------------------------------------------------------
  -- 3) Carrega cabeçalho e itens da composição
  ------------------------------------------------------------
  DECLARE
    @cd_modulo            INT,
    @cd_etapa             INT,
    @cd_usuario_relatorio INT,
    @cd_relatorio         INT;

  SELECT
    @cd_modulo            = F.cd_modulo,
    @cd_etapa             = F.cd_etapa,
    @cd_usuario_relatorio = F.cd_usuario_relatorio,
    @cd_relatorio         = F.cd_relatorio
  FROM Fila_Servico_Relatorio F
  WHERE F.cd_fila = @cd_fila;

  IF @cd_relatorio IS NULL
  BEGIN
      UPDATE Fila_Servico_Relatorio
      SET cd_status_relatorio = 9, ds_ocorrencia = 'Sem cd_relatorio', dt_usuario = GETDATE()
      WHERE cd_fila = @cd_fila;
      --RETURN;

    RAISERROR('Fila %d sem cd_relatorio definido.', 16, 1, @cd_fila);
    RETURN;

  END

  DECLARE @itens TABLE(
    cd_documento       INT,
    cd_item_documento  INT,
    cd_ordem_impressao INT
  );

  INSERT INTO @itens(cd_documento, cd_item_documento, cd_ordem_impressao)
  SELECT
    ISNULL(cd_documento,0),
    ISNULL(cd_item_documento,0),
    ISNULL(cd_ordem_impressao,1)
  FROM Fila_Servico_Relatorio_Composicao
  WHERE cd_fila = @cd_fila
  ORDER BY ISNULL(cd_ordem_impressao,1), ISNULL(cd_documento,0), ISNULL(cd_item_documento,0);

  ------------------------------------------------------------
  -- 4) Processa item a item chamando pr_egis_relatorio_padrao
  ------------------------------------------------------------
  DECLARE
    @doc   INT,
    @item  INT,
    @ord   INT,
    @jsonCall NVARCHAR(MAX),
    @html     NVARCHAR(MAX),
    @nmArq NVARCHAR(260);

  DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT cd_documento, cd_item_documento, cd_ordem_impressao FROM @itens;

  OPEN cur;
  FETCH NEXT FROM cur INTO @doc, @item, @ord;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    BEGIN TRY
      -- JSON esperado pela sua pr_egis_relatorio_padrao
      SET @jsonCall = N'[
        {
          "ic_json_parametro": "S",
          "cd_parametro": 0,
          "cd_usuario": ' + CAST(@cd_usuario_relatorio AS NVARCHAR(20)) + N',
          "cd_modulo": '  + CAST(@cd_modulo AS NVARCHAR(20))            + N',
          "cd_etapa": '   + CAST(@cd_etapa AS NVARCHAR(20))             + N',
          "cd_relatorio": ' + CAST(@cd_relatorio AS NVARCHAR(20))       + N',
          "cd_documento": ' + CAST(@doc AS NVARCHAR(20))                 + N',
          "cd_item_documento": ' + CAST(@item AS NVARCHAR(20))           + N'
        }
      ]';

      -- A procedure de relatório retorna um recordset com a coluna RelatorioHTML
      --   CREATE TABLE #html(html NVARCHAR(MAX) NULL);
      DECLARE @t TABLE(RelatorioHTML NVARCHAR(MAX));
      INSERT INTO @t(RelatorioHTML)
      EXEC dbo.pr_egis_relatorio_padrao @json = @jsonCall;

      SELECT TOP 1 @html = RelatorioHTML FROM @t;

      IF (@html IS NULL OR LEN(@html)=0)
      begin
        SET @jsonCall = JSON_MODIFY(@jsonCall,'$[0].cd_parametro',1);
        delete from @t;
        INSERT INTO @t EXEC dbo.pr_egis_relatorio_padrao @json=@jsonCall

        SELECT TOP 1 @html = RelatorioHTML FROM @t;
        
      end
      
      -----------------------
      --drop table @t
      -----------------------

      IF (@html IS NULL OR LEN(@html)=0)
          SET @html = N'<h3>Relatório vazio - verifique o se existe o cadastro do relatório ou documento correto !.</h3>';
      
      -- Salva (opcional) na tabela de saída
      SET @nmArq = CONCAT('rel_', @cd_fila, '_', @doc, '_', @item, '.html');
      INSERT INTO Fila_Servico_Relatorio_Saida(cd_fila, cd_documento, cd_item_documento, nm_arquivo, ds_html)
      VALUES (@cd_fila, @doc, @item, @nmArq, @html);

      -- Marca ocorrência no item (se a coluna existir)
      IF COL_LENGTH('dbo.Fila_Servico_Relatorio_Composicao','ds_ocorrencia') IS NOT NULL
      BEGIN
        UPDATE Fila_Servico_Relatorio_Composicao
           SET ds_ocorrencia = CONCAT('OK: ', @nmArq), dt_usuario = GETDATE()
         WHERE cd_fila = @cd_fila AND ISNULL(cd_documento,0)=@doc AND ISNULL(cd_item_documento,0)=@item;
      END

      SET @ok += 1;

    END TRY
    BEGIN CATCH
      SET @erros += 1;
      DECLARE @msg NVARCHAR(4000) = CONCAT('ERRO: ', ERROR_MESSAGE());
      IF COL_LENGTH('Fila_Servico_Relatorio_Composicao','ds_ocorrencia') IS NOT NULL
      BEGIN
        UPDATE Fila_Servico_Relatorio_Composicao
           SET ds_ocorrencia = @msg, dt_usuario = GETDATE()
         WHERE cd_fila = @cd_fila AND ISNULL(cd_documento,0)=@doc AND ISNULL(cd_item_documento,0)=@item;
      END
    END CATCH;

    FETCH NEXT FROM cur INTO @doc, @item, @ord;
  END

  CLOSE cur; DEALLOCATE cur;

  ------------------------------------------------------------
  -- 5) Finaliza o cabeçalho (3=Concluído, 9=Erro)
  ------------------------------------------------------------
  UPDATE Fila_Servico_Relatorio
     SET cd_status_relatorio = CASE WHEN @erros = 0 THEN 3 ELSE 9 END,
         dt_usuario           = GETDATE(),
         ds_ocorrencia        = CONCAT(ISNULL(ds_ocorrencia,''), ' [', CONVERT(varchar(19),GETDATE(),120), '] fim; ok=', @ok, '; erro=', @erros)
   WHERE cd_fila = @cd_fila;

  ------------------------------------------------------------
  -- 6) Retorno (resumo)
  ------------------------------------------------------------
  SELECT
    cd_fila        = @cd_fila,
    itens_total    = (SELECT COUNT(1) FROM @itens),
    itens_ok       = @ok,
    itens_erro     = @erros,
    status_final   = CASE WHEN @erros=0 THEN 3 ELSE 9 END;
END
GO


-----------------------------------------------------------------------

--DECLARE @json NVARCHAR(MAX) =
--N'[
--  { "ic_json_parametro":"S", "cd_parametro":1, "cd_fila": 123 }
--]';
--EXEC pr_egis_processa_fila_relatorio @json=@json;

-----------------------------------------------------------------------

go

--SELECT TOP 20 * 
--FROM Fila_Servico_Relatorio_Saida
--WHERE cd_fila = 123
--ORDER BY cd_fila_arquivo DESC;
