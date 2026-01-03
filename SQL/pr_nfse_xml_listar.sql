IF OBJECT_ID('dbo.pr_nfse_xml_listar', 'P') IS NOT NULL
  DROP PROCEDURE dbo.pr_nfse_xml_listar;
GO

CREATE PROCEDURE dbo.pr_nfse_xml_listar
  @json NVARCHAR(MAX) = N''
AS
BEGIN
  SET NOCOUNT ON;

  -------------------------------------------------------------------------
  -- valida payload
  -------------------------------------------------------------------------
  IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
  BEGIN
    SELECT 0 AS sucesso, 400 AS codigo, N'Payload JSON inválido/vazio.' AS mensagem;
    RETURN;
  END;

  -- se vier array, pega o primeiro objeto
  IF JSON_VALUE(@json, '$[0]') IS NOT NULL
    SET @json = JSON_QUERY(@json, '$[0]');

  -------------------------------------------------------------------------
  -- parâmetros
  -------------------------------------------------------------------------
  DECLARE
    @dt_ini_date  date = TRY_CONVERT(date, JSON_VALUE(@json,'$.dt_inicial')),
    @dt_fim_date  date = TRY_CONVERT(date, JSON_VALUE(@json,'$.dt_final')),
    @cnpj_prestador varchar(20) = NULLIF(JSON_VALUE(@json,'$.cnpj_prestador'), ''),
    @nr_nfse        varchar(30) = NULLIF(JSON_VALUE(@json,'$.nr_nfse'), ''),
    @cd_verificacao varchar(60) = NULLIF(JSON_VALUE(@json,'$.cd_verificacao'), '');

  -- defaults: mês atual (igual seu comportamento na tela)
  IF @dt_ini_date IS NULL
    SET @dt_ini_date = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);

  IF @dt_fim_date IS NULL
    SET @dt_fim_date = EOMONTH(@dt_ini_date);

  DECLARE
    @dt_ini datetime = CONVERT(datetime, @dt_ini_date),
    @dt_fim_exclusive datetime = DATEADD(DAY, 1, CONVERT(datetime, @dt_fim_date));

  -------------------------------------------------------------------------
  -- dados (IMPORTANTE: filtra por dt_usuario_inclusao primeiro)
  -------------------------------------------------------------------------
  SELECT
    n.cd_nfse_xml,
    n.cd_empresa,
    n.cd_usuario_inclusao,
    n.dt_usuario_inclusao,

    n.dt_emissao,
    n.nr_nfse,
    n.cd_verificacao,
    n.cnpj_prestador,
    n.cnpj_tomador,
    n.im_prestador,

    n.vl_servicos,
    n.vl_iss,
    n.vl_liquido,
    n.aliq_iss,
    n.base_calculo,
    n.item_lista_servico,
    n.cod_trib_municipio,
    n.municipio_prestacao,

    LEFT(REPLACE(REPLACE(n.ds_discriminacao, CHAR(10), ' '), CHAR(13), ' '), 200) AS ds_preview
  FROM dbo.nfse_xml n WITH (NOLOCK)
  WHERE
      ISNULL(n.dt_usuario_inclusao, n.dt_emissao) >= @dt_ini
  AND ISNULL(n.dt_usuario_inclusao, n.dt_emissao) <  @dt_fim_exclusive
  AND (@cnpj_prestador IS NULL OR n.cnpj_prestador = @cnpj_prestador)
  AND (@nr_nfse IS NULL OR n.nr_nfse = @nr_nfse)
  AND (@cd_verificacao IS NULL OR n.cd_verificacao = @cd_verificacao)
  ORDER BY ISNULL(n.dt_usuario_inclusao, n.dt_emissao) DESC, n.cd_nfse_xml DESC;

  SELECT 1 AS sucesso, 200 AS codigo, N'OK' AS mensagem;
END
GO
