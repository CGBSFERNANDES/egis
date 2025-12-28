
IF OBJECT_ID('dbo.pr_egis_atributos_tabela','P') IS NOT NULL
  DROP PROCEDURE dbo.pr_egis_atributos_tabela;
GO
CREATE PROCEDURE dbo.pr_egis_atributos_tabela
     @cd_tabela INT
AS
--select * from egisadmin.dbo.atributo
BEGIN
  
  SET NOCOUNT ON;
  
  SELECT
      t.nm_tabela,
      a.cd_tabela,
      a.cd_atributo,
      a.nm_atributo,
      a.ds_atributo                     as nm_titulo,
      n.nm_natureza_atributo,
      n.nm_formato,
      n.nm_datatype

  FROM
    egisadmin.dbo.atributo a
    inner join egisadmin.dbo.tabela t                      on t.cd_tabela = a.cd_tabela
    left outer join egisadmin.dbo.natureza_atributo n on n.cd_natureza_atributo = a.cd_natureza_atributo

  WHERE a.cd_tabela = @cd_tabela
  ORDER BY a.cd_tabela, a.cd_atributo --nm_atributo;
END
GO

-----------------------------------
--exec pr_egis_atributos_tabela 93
-----------------------------------