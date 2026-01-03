IF OBJECT_ID('dbo.pr_cte_xml_listar', 'P') IS NOT NULL
  DROP PROCEDURE dbo.pr_cte_xml_listar;
GO

CREATE PROCEDURE dbo.pr_cte_xml_listar
(
  @json NVARCHAR(MAX)
)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE
    @cd_empresa    INT,
    @cd_tipo_xml   INT,
    @dt_ini_str    NVARCHAR(20),
    @dt_fim_str    NVARCHAR(20);

  ;WITH P AS
  (
    -- Aceita tanto [{"..."}] quanto {"..."}
    SELECT TOP (1) *
    FROM OPENJSON(@json)
    WITH
    (
      cd_empresa   INT          '$.cd_empresa',
      cd_tipo_xml  INT          '$.cd_tipo_xml',
      dt_inicial   NVARCHAR(20) '$.dt_inicial',
      dt_final     NVARCHAR(20) '$.dt_final'
    )
  )
  SELECT
    @cd_empresa  = cd_empresa,
    @cd_tipo_xml = cd_tipo_xml,
    @dt_ini_str  = dt_inicial,
    @dt_fim_str  = dt_final
  FROM P;

  -- Converte datas (aceita dd/MM/yyyy; se vier yyyy-MM-dd também funciona)
  DECLARE @dt_ini DATE =
      COALESCE(TRY_CONVERT(DATE, @dt_ini_str, 103), TRY_CONVERT(DATE, @dt_ini_str, 23));
  DECLARE @dt_fim DATE =
      COALESCE(TRY_CONVERT(DATE, @dt_fim_str, 103), TRY_CONVERT(DATE, @dt_fim_str, 23));

  -- Defaults defensivos
  IF @dt_ini IS NULL SET @dt_ini = DATEADD(DAY, -30, CONVERT(DATE, GETDATE()));
  IF @dt_fim IS NULL SET @dt_fim = CONVERT(DATE, GETDATE());

  DECLARE @ini DATETIME2(0) = CONVERT(DATETIME2(0), @dt_ini);
  DECLARE @fim DATETIME2(0) = DATEADD(DAY, 1, CONVERT(DATETIME2(0), @dt_fim)); -- exclusivo

  SELECT
      a.cd_cte_xml,
      a.cd_empresa,
      a.cd_usuario_inclusao,
      a.dt_usuario_inclusao,
      a.ds_layout,
      a.ch_cte,
      a.nr_cte,
      a.serie,
      a.dt_emissao,
      a.tp_cte,
      a.tp_serv,
      a.modal,
      a.cfop,
      a.cnpj_emit,
      a.xnome_emit,
      a.cnpj_dest,
      a.xnome_dest,
      a.uf_ini,
      a.uf_fim,
      a.xmun_ini,
      a.xmun_fim,
      a.v_tprest,
      a.v_rec,
      a.v_carga,
      a.pro_pred,
      a.hash_xml
  FROM dbo.cte_xml a WITH (NOLOCK)
  WHERE
      (@cd_empresa  IS NULL OR a.cd_empresa  = @cd_empresa)
      AND (@cd_tipo_xml IS NULL OR a.ds_layout = 'CTE' OR @cd_tipo_xml = @cd_tipo_xml) -- se você usa cd_tipo_xml na tabela, troque aqui
      AND COALESCE(a.dt_usuario_inclusao, a.dt_emissao) >= @ini
      AND COALESCE(a.dt_usuario_inclusao, a.dt_emissao) <  @fim
  ORDER BY
      COALESCE(a.dt_emissao, a.dt_usuario_inclusao) DESC,
      a.cd_cte_xml DESC;
END
GO

--EXEC dbo.pr_cte_xml_listar N'[{"cd_empresa":377,"dt_inicial":"01/01/2026","dt_final":"01/01/2027"}]';

