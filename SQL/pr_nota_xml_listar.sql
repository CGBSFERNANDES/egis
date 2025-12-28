IF OBJECT_ID('pr_nota_xml_listar', 'P') IS NOT NULL
  DROP PROCEDURE pr_nota_xml_listar;
GO


CREATE PROCEDURE pr_nota_xml_listar
  @cd_tipo_xml INT = NULL,
  @dt_ini      DATETIME = NULL,
  @dt_fim      DATETIME = NULL
AS
BEGIN
  set @cd_tipo_xml = isnull(@cd_tipo_xml,0) 

  SET NOCOUNT ON;

  --select @dt_ini, @dt_fim

  --nfe_nota

  SELECT
    n.cd_xml_nota,
    n.cd_tipo_xml,
    nfe.cd_identificacao,
    cast('' as varchar(80)) AS nm_emitente,
    nfe.dt_emissao_nota as dt_emissao_nota,
    nfe.dt_entrada_nota,
    case when isnull(n.cd_chave_acesso,'')<>'' then
       n.cd_chave_acesso
    else
       nfe.cd_chave_acesso
    end                 as cd_chave_acesso,
    d.nm_destinatario,
    e.nm_emitente,

    n.cd_usuario_inclusao,
    n.dt_usuario_inclusao,
    n.ds_xml,

    -- opcional: um preview do XML (primeiros 200 chars) para mostrar na grid
    LEFT(REPLACE(REPLACE(n.ds_xml, CHAR(10), ' '), CHAR(13), ' '), 200) AS ds_xml_preview,
    --------------------------------------------------------------------------------------
    cd_operacao_fiscal   as cd_operacao_fiscal,
    xPed                 as xPed,
    nItemPed             as nItemPed,
    cd_aplicacao_produto as cd_aplicacao_produto,
    cd_plano_financeiro  as cd_plano_financeiro,    
    n.cd_nota_entrada    as cd_nota_entrada




    --select * from nfe_destinatario
    --select * from nfe_emitente
    --select * from nota_entrada

  
  FROM
    nota_xml n
    left outer join NFE_Nota nfe       on nfe.cd_chave_acesso = n.cd_chave_acesso
    left outer join NFE_Destinatario d on d.cd_destinatario   = nfe.cd_destinatario
    left outer join NFE_Emitente e     on e.cd_emitente       = nfe.cd_emitente

  WHERE
    --(@cd_tipo_xml IS NULL OR n.cd_tipo_xml = @cd_tipo_xml)
   -- and
    n.cd_tipo_xml = case when @cd_tipo_xml = 0 then n.cd_tipo_xml else @cd_tipo_xml end

    AND (@dt_ini IS NULL OR n.dt_usuario_inclusao >= @dt_ini)
    AND (@dt_fim IS NULL OR n.dt_usuario_inclusao <  DATEADD(DAY, 1, @dt_fim))

  ORDER BY n.cd_xml_nota DESC;

  --select * from nota_xml

END
GO



--exec pr_nota_xml_listar 0,'10/01/2025','12/30/2025'

