--pr_egis_gera_nota_saida_documento
--BANCO DO CLIENTE
--USE EGISSQL_319
DROP PROCEDURE pr_egis_gera_nota_saida_documento
GO
CREATE PROCEDURE pr_egis_gera_nota_saida_documento
  @cd_nota_documento     VARCHAR(44),
  @cd_nota_saida         INT,
  @cd_tipo_documento     INT = 1,
  @ds_nota_documento     XML,
  @ds_nota_xml_retorno   XML = NULL,
  @cd_usuario            INT
AS
BEGIN
  SET NOCOUNT ON;

  IF EXISTS (
    SELECT 1 FROM nota_saida_documento 
    WHERE cd_nota_documento = @cd_nota_documento
      AND cd_nota_saida = @cd_nota_saida
  )
  BEGIN
    -- Atualiza se já existe
    UPDATE nota_saida_documento
    SET
      ds_nota_documento = @ds_nota_documento,
      ds_nota_xml_retorno = @ds_nota_xml_retorno,
      dt_usuario = GETDATE(),
      cd_usuario = @cd_usuario
    WHERE
      cd_nota_documento = @cd_nota_documento
      AND cd_nota_saida = @cd_nota_saida;
  END
  ELSE
  BEGIN
    -- Insere novo registro
    INSERT INTO nota_saida_documento (
      cd_nota_documento,
      cd_nota_saida,
      cd_tipo_documento,
      ds_nota_documento,
      ds_nota_xml_retorno,
      cd_usuario,
      dt_usuario
    )
    VALUES (
      @cd_nota_documento,
      @cd_nota_saida,
      @cd_tipo_documento,
      @ds_nota_documento,
      @ds_nota_xml_retorno,
      @cd_usuario,
      GETDATE()
    );
  END
END;
