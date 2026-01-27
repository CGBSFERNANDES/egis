------------------------------------------------------------------------------------
-- Cadastro do relatório cd_relatorio = 445 (Inventário do Bem do Ativo)
------------------------------------------------------------------------------------
-- Observação: ajustar as colunas obrigatórias conforme o ambiente antes de executar.
------------------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM egisadmin.dbo.relatorio WITH (NOLOCK)
    WHERE cd_relatorio = 445
)
BEGIN
    INSERT INTO egisadmin.dbo.relatorio (
        cd_relatorio,
        nm_relatorio,
        nm_titulo_relatorio,
        nm_procedure_relatorio,
        ic_grafico
        -- TODO: incluir demais colunas NOT NULL exigidas no ambiente (ex.: cd_modulo, ic_grid_relatorio, ic_ativo, cd_form, etc.)
    )
    VALUES (
        445,
        'Inventário do Bem do Ativo',
        'Inventário do Bem do Ativo',
        'pr_egis_relatorio_inventario_ativo_periodo',
        'N'
        -- TODO: preencher os demais valores obrigatórios conforme o schema real
    );
END;
