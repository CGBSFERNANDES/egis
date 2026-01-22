------------------------------------------------------------------------------------
-- Cadastro do relatório cd_relatorio = 434 (Ordem de Serviço Consultoria)
------------------------------------------------------------------------------------
-- Observação: ajustar as colunas obrigatórias conforme o ambiente antes de executar.
------------------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM egisadmin.dbo.relatorio WITH (NOLOCK)
    WHERE cd_relatorio = 434
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
        434,
        'Ordem de Serviço Consultoria',
        'Ordem de Serviço Consultoria',
        'pr_egis_relatorio_ordem_servico_consultoria',
        'N'
        -- TODO: preencher os demais valores obrigatórios conforme o schema real
    );
END;
