IF EXISTS (
    SELECT name
    FROM sys.objects
    WHERE name = N'pr_egis_declaracao_conteudo'
      AND type = 'P'
)
    DROP PROCEDURE pr_egis_declaracao_conteudo
GO
------------------------------------------------------------------------------------
-- pr_egis_declaracao_conteudo
------------------------------------------------------------------------------------
-- GBS - Global Business Solution                                            2025
------------------------------------------------------------------------------------
-- Stored Procedure : Microsoft SQL Server 2016
-- Autor(es)        : Codex
-- Banco de Dados   : EGISSQL
-- Objetivo         : Relatório HTML - Declaração de Conteúdo (Correios) - cd_relatorio = 406
-- Data             : 2025-01-XX
-- Observações      : Compatível com SQL Server 2016. Utiliza apenas as views autorizadas.
------------------------------------------------------------------------------------
/*
  Dicionário mínimo (colunas utilizadas)
  - vw_nfe_emitente_nota_fiscal: cd_identificacao_nota_saida, dt_nota_saida, cd_nota_saida,
    xNome, xFant, CNPJ, IE, xLgr, xCpl, nro, xBairro, xMun, UF, CEP, fone
  - vw_nfe_destintario_nota_fiscal: cd_identificacao_nota_saida, dt_nota_saida, cd_nota_saida,
    xNome, xFant, CNPJ2, CPF, xLgr, xCpl, nro, xBairro, xMun, UF, CEP, fone
  - vw_nfe_produto_servico_nota_fiscal_api: cd_identificacao_nota_saida, dt_nota_saida, cd_nota_saida,
    nItem, cProd, xprod, qCom, uCom, vProd
*/
CREATE PROCEDURE pr_egis_declaracao_conteudo
    @json NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @notas TABLE (cd_nota_saida INT PRIMARY KEY);
        DECLARE @html NVARCHAR(MAX) = N'';

        IF ISNULL(@json, N'') = N'' OR ISJSON(@json) <> 1
        BEGIN
            THROW 50000, 'JSON de entrada inválido ou vazio.', 1;
        END;

        INSERT INTO @notas (cd_nota_saida)
        SELECT DISTINCT j.cd_nota_saida
        FROM OPENJSON(@json)
            WITH (cd_nota_saida INT '$.cd_nota_saida') AS j
        WHERE j.cd_nota_saida IS NOT NULL;

        IF NOT EXISTS (SELECT 1 FROM @notas)
            OR EXISTS (SELECT 1 FROM @notas WHERE cd_nota_saida <= 0)
        BEGIN
            THROW 50001, 'É necessário informar ao menos um cd_nota_saida válido (> 0).', 1;
        END;

        DECLARE @style NVARCHAR(MAX) = N'
<style>
  .declaracao { width: 100%; max-width: 680px; font-family: Arial, sans-serif; font-size: 12px; color: #000; }
  .cabecalho { text-align: center; margin-bottom: 10px; }
  .secao { margin-bottom: 10px; border: 1px solid #000; padding: 8px; }
  .secao-titulo { font-weight: bold; text-transform: uppercase; margin-bottom: 6px; }
  .linha { margin-bottom: 4px; }
  .label { font-weight: bold; }
  .itens { width: 100%; border-collapse: collapse; }
  .itens th, .itens td { border: 1px solid #000; padding: 4px; text-align: left; }
  .page-break { page-break-after: always; }
</style>';

        SET @html = @style;

        ;WITH emitente AS (
            SELECT
                n.cd_nota_saida,
                e.xNome,
                e.xFant,
                e.CNPJ,
                e.IE,
                e.xLgr,
                e.xCpl,
                e.nro,
                e.xBairro,
                e.xMun,
                e.UF,
                e.CEP,
                e.fone
            FROM @notas AS n
            OUTER APPLY (
                SELECT TOP (1)
                    ve.xNome,
                    ve.xFant,
                    ve.CNPJ,
                    ve.IE,
                    ve.xLgr,
                    ve.xCpl,
                    ve.nro,
                    ve.xBairro,
                    ve.xMun,
                    ve.UF,
                    ve.CEP,
                    ve.fone
                FROM vw_nfe_emitente_nota_fiscal AS ve
                WHERE ve.cd_nota_saida = n.cd_nota_saida
                ORDER BY ve.cd_identificacao_nota_saida
            ) AS e
        ),
        destinatario AS (
            SELECT
                n.cd_nota_saida,
                d.xNome,
                d.xFant,
                COALESCE(NULLIF(d.CNPJ2, ''), NULLIF(d.CPF, '')) AS Documento,
                d.xLgr,
                d.xCpl,
                d.nro,
                d.xBairro,
                d.xMun,
                d.UF,
                d.CEP,
                d.fone
            FROM @notas AS n
            OUTER APPLY (
                SELECT TOP (1)
                    vd.xNome,
                    vd.xFant,
                    vd.CNPJ2,
                    vd.CPF,
                    vd.xLgr,
                    vd.xCpl,
                    vd.nro,
                    vd.xBairro,
                    vd.xMun,
                    vd.UF,
                    vd.CEP,
                    vd.fone
                FROM vw_nfe_destintario_nota_fiscal AS vd
                WHERE vd.cd_nota_saida = n.cd_nota_saida
                ORDER BY vd.cd_identificacao_nota_saida
            ) AS d
        ),
        itens AS (
            SELECT
                n.cd_nota_saida,
                (
                    SELECT
                        '<tr>' +
                        '<td>' + ISNULL(p.cProd, '') + '</td>' +
                        '<td>' + ISNULL(p.xprod, '') + '</td>' +
                        '<td>' + ISNULL(p.qCom, '') + ' ' + ISNULL(p.uCom, '') + '</td>' +
                        '<td>' + ISNULL(p.vProd, '') + '</td>' +
                        '</tr>'
                    FROM vw_nfe_produto_servico_nota_fiscal_api AS p
                    WHERE p.cd_nota_saida = n.cd_nota_saida
                    ORDER BY p.nItem
                    FOR XML PATH(''), TYPE
                ).value('.', 'NVARCHAR(MAX)') AS itens_html
            FROM @notas AS n
        ),
        base AS (
            SELECT
                n.cd_nota_saida,
                ROW_NUMBER() OVER (ORDER BY n.cd_nota_saida) AS rn,
                COUNT(*) OVER () AS total_notas,
                em.xNome AS nm_emitente,
                em.xFant AS nm_fantasia_emitente,
                em.CNPJ AS cnpj_emitente,
                em.IE AS ie_emitente,
                em.xLgr AS logradouro_emitente,
                em.xCpl AS complemento_emitente,
                em.nro AS numero_emitente,
                em.xBairro AS bairro_emitente,
                em.xMun AS cidade_emitente,
                em.UF AS uf_emitente,
                em.CEP AS cep_emitente,
                em.fone AS fone_emitente,
                de.xNome AS nm_destinatario,
                de.xFant AS nm_fantasia_destinatario,
                de.Documento AS doc_destinatario,
                de.xLgr AS logradouro_destinatario,
                de.xCpl AS complemento_destinatario,
                de.nro AS numero_destinatario,
                de.xBairro AS bairro_destinatario,
                de.xMun AS cidade_destinatario,
                de.UF AS uf_destinatario,
                de.CEP AS cep_destinatario,
                de.fone AS fone_destinatario,
                it.itens_html
            FROM @notas AS n
            LEFT JOIN emitente AS em ON em.cd_nota_saida = n.cd_nota_saida
            LEFT JOIN destinatario AS de ON de.cd_nota_saida = n.cd_nota_saida
            LEFT JOIN itens AS it ON it.cd_nota_saida = n.cd_nota_saida
        )
        SELECT
            @html = @html +
                '<div class="declaracao">' +
                    '<div class="cabecalho"><h2>Declaração de Conteúdo</h2></div>' +
                    '<div class="secao">' +
                        '<div class="secao-titulo">Remetente</div>' +
                        '<div class="linha"><span class="label">Nome/Razão Social:</span> ' + ISNULL(nm_emitente, '') + '</div>' +
                        '<div class="linha"><span class="label">Nome Fantasia:</span> ' + ISNULL(nm_fantasia_emitente, '') + '</div>' +
                        '<div class="linha"><span class="label">CNPJ:</span> ' + ISNULL(cnpj_emitente, '') + ' <span class="label">IE:</span> ' + ISNULL(ie_emitente, '') + '</div>' +
                        '<div class="linha"><span class="label">Endereço:</span> ' + ISNULL(logradouro_emitente, '') +
                            CASE WHEN ISNULL(complemento_emitente, '') <> '' THEN ' - ' + complemento_emitente ELSE '' END +
                            ', ' + ISNULL(numero_emitente, '') + ' - ' + ISNULL(bairro_emitente, '') + '</div>' +
                        '<div class="linha"><span class="label">Cidade/UF:</span> ' + ISNULL(cidade_emitente, '') + '/' + ISNULL(uf_emitente, '') +
                            ' <span class="label">CEP:</span> ' + ISNULL(cep_emitente, '') +
                            CASE WHEN ISNULL(fone_emitente, '') <> '' THEN ' <span class="label">Fone:</span> ' + fone_emitente ELSE '' END +
                        '</div>' +
                    '</div>' +
                    '<div class="secao">' +
                        '<div class="secao-titulo">Destinatário</div>' +
                        '<div class="linha"><span class="label">Nome/Razão Social:</span> ' + ISNULL(nm_destinatario, '') + '</div>' +
                        '<div class="linha"><span class="label">Nome Fantasia:</span> ' + ISNULL(nm_fantasia_destinatario, '') + '</div>' +
                        '<div class="linha"><span class="label">Documento:</span> ' + ISNULL(doc_destinatario, '') + '</div>' +
                        '<div class="linha"><span class="label">Endereço:</span> ' + ISNULL(logradouro_destinatario, '') +
                            CASE WHEN ISNULL(complemento_destinatario, '') <> '' THEN ' - ' + complemento_destinatario ELSE '' END +
                            ', ' + ISNULL(numero_destinatario, '') + ' - ' + ISNULL(bairro_destinatario, '') + '</div>' +
                        '<div class="linha"><span class="label">Cidade/UF:</span> ' + ISNULL(cidade_destinatario, '') + '/' + ISNULL(uf_destinatario, '') +
                            ' <span class="label">CEP:</span> ' + ISNULL(cep_destinatario, '') +
                            CASE WHEN ISNULL(fone_destinatario, '') <> '' THEN ' <span class="label">Fone:</span> ' + fone_destinatario ELSE '' END +
                        '</div>' +
                    '</div>' +
                    '<div class="secao">' +
                        '<div class="secao-titulo">Identificação dos Bens</div>' +
                        '<table class="itens">' +
                            '<thead><tr><th>Código</th><th>Descrição</th><th>Quantidade</th><th>Valor</th></tr></thead>' +
                            '<tbody>' + ISNULL(itens_html, '<tr><td colspan="4">Nenhum item encontrado</td></tr>') + '</tbody>' +
                        '</table>' +
                    '</div>' +
                '</div>' +
                CASE WHEN rn < total_notas THEN '<div class="page-break"></div>' ELSE '' END
        FROM base;

        SELECT ISNULL(@html, N'') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50010, @ErrorMessage, 1;
    END CATCH;
END;
GO
