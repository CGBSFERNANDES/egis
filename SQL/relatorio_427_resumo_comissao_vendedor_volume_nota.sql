/*-----------------------------------------------------------------------------------------------
  Cadastro do Relatório 427 - Resumo de Comissão por Vendedor
-----------------------------------------------------------------------------------------------*/
IF NOT EXISTS (
    SELECT 1
    FROM egisadmin.dbo.Relatorio WITH (NOLOCK)
    WHERE cd_relatorio = 427
)
BEGIN
    INSERT INTO egisadmin.dbo.Relatorio (
        cd_relatorio,
        nm_relatorio,
        nm_titulo_relatorio,
        ds_relatorio,
        ic_empresa,
        ic_grid_relatorio,
        nm_arquivo_relatorio,
        nm_extensao_arquivo
    )
    VALUES (
        427,
        'Resumo de Comissão por Vendedor',
        'Resumo de Comissão por Vendedor',
        'Relatório HTML de resumo de comissão por vendedor.',
        'S',
        'S',
        'ResumoComissaoVendedor',
        'html'
    );
END;
GO
