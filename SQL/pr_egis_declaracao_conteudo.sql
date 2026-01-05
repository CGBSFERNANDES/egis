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
  .declaracao { width: 100%; max-width: 720px; font-family: Arial, sans-serif; font-size: 12px; color: #000; margin: 0 auto; }
  .titulo { text-align: center; font-size: 16px; font-weight: bold; letter-spacing: 1px; border: 1px solid #000; padding: 6px 0; }
  .tabela { width: 100%; border-collapse: collapse; border: 1px solid #000; margin-top: 4px; }
  .tabela th, .tabela td { border: 1px solid #000; padding: 4px; vertical-align: top; }
  .secao-cabecalho th { text-transform: uppercase; font-weight: bold; }
  .subtitulo { font-weight: bold; text-transform: uppercase; text-align: center; border: 1px solid #000; padding: 4px 0; margin-top: 6px; }
  .itens thead th { text-align: center; font-weight: bold; }
  .itens td { font-size: 11px; }
  .totais td { font-weight: bold; }
  .peso-row td { font-weight: bold; }
  .declaracao-bloco { border: 1px solid #000; padding: 8px; margin-top: 6px; }
  .declaracao-titulo { text-align: center; font-weight: bold; letter-spacing: 1px; margin-bottom: 6px; }
  .assinatura { width: 100%; text-align: center; margin-top: 14px; }
  .assinatura td { border-top: 1px solid #000; padding-top: 6px; }
  .observacao { border: 1px solid #000; padding: 6px; margin-top: 6px; font-weight: bold; }
  .observacao-texto { font-weight: normal; }
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
        itens_detalhe AS (
            SELECT
                p.cd_nota_saida,
                ROW_NUMBER() OVER (PARTITION BY p.cd_nota_saida ORDER BY p.nItem) AS nr_item,
                ISNULL(p.cProd, '') AS cProd,
                ISNULL(p.xprod, '') AS xprod,
                ISNULL(p.qCom, '') AS qCom,
                ISNULL(p.uCom, '') AS uCom,
                ISNULL(p.vProd, '') AS vProd
            FROM vw_nfe_produto_servico_nota_fiscal_api AS p
            INNER JOIN @notas AS n ON n.cd_nota_saida = p.cd_nota_saida
        ),
        itens_html AS (
            SELECT
                d.cd_nota_saida,
                (
                    SELECT
                        '<tr>' +
                        '<td style="text-align:center;">' + CAST(d2.nr_item AS NVARCHAR(10)) + '</td>' +
                        '<td>' + d2.xprod + '</td>' +
                        '<td style="text-align:center;">' + d2.qCom + ' ' + d2.uCom + '</td>' +
                        '<td style="text-align:right;">' + d2.vProd + '</td>' +
                        '</tr>'
                    FROM itens_detalhe AS d2
                    WHERE d2.cd_nota_saida = d.cd_nota_saida
                    ORDER BY d2.nr_item
                    FOR XML PATH(''), TYPE
                ).value('.', 'NVARCHAR(MAX)') AS itens_html
            FROM itens_detalhe AS d
            GROUP BY d.cd_nota_saida
        ),
        itens_totais AS (
            SELECT
                p.cd_nota_saida,
                SUM(TRY_CONVERT(DECIMAL(18, 3), REPLACE(REPLACE(p.qCom, '.', ''), ',', '.'))) AS qt_total,
                SUM(TRY_CONVERT(DECIMAL(18, 2), REPLACE(REPLACE(p.vProd, '.', ''), ',', '.'))) AS vl_total,
                NULL AS peso_total -- TODO: mapear coluna de peso total (kg) na view vw_nfe_produto_servico_nota_fiscal_api
            FROM itens_detalhe AS p
            GROUP BY p.cd_nota_saida
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
                ih.itens_html,
                ISNULL(tt.qt_total, 0) AS qt_total,
                ISNULL(tt.vl_total, 0) AS vl_total,
                tt.peso_total
            FROM @notas AS n
            LEFT JOIN emitente AS em ON em.cd_nota_saida = n.cd_nota_saida
            LEFT JOIN destinatario AS de ON de.cd_nota_saida = n.cd_nota_saida
            LEFT JOIN itens_html AS ih ON ih.cd_nota_saida = n.cd_nota_saida
            LEFT JOIN itens_totais AS tt ON tt.cd_nota_saida = n.cd_nota_saida
        )
        SELECT
            @html = @html +
                '<div class="declaracao">' +
                    '<div class="titulo">DECLARAÇÃO DE CONTEÚDO</div>' +
                    '<table class="tabela secao-cabecalho">' +
                        '<tr><th colspan="2">REMETENTE</th><th colspan="2">DESTINATÁRIO</th></tr>' +
                        '<tr>' +
                            '<td colspan="2"><strong>Nome:</strong> ' + ISNULL(nm_emitente, '') + '</td>' +
                            '<td colspan="2"><strong>Nome:</strong> ' + ISNULL(nm_destinatario, '') + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '<td colspan="2"><strong>Endereço:</strong> ' + ISNULL(logradouro_emitente, '') +
                                CASE WHEN ISNULL(complemento_emitente, '') <> '' THEN ' - ' + complemento_emitente ELSE '' END +
                                ', ' + ISNULL(numero_emitente, '') + ' - ' + ISNULL(bairro_emitente, '') + '</td>' +
                            '<td colspan="2"><strong>Endereço:</strong> ' + ISNULL(logradouro_destinatario, '') +
                                CASE WHEN ISNULL(complemento_destinatario, '') <> '' THEN ' - ' + complemento_destinatario ELSE '' END +
                                ', ' + ISNULL(numero_destinatario, '') + ' - ' + ISNULL(bairro_destinatario, '') + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '<td><strong>Cidade:</strong> ' + ISNULL(cidade_emitente, '') + '</td>' +
                            '<td><strong>UF:</strong> ' + ISNULL(uf_emitente, '') + '</td>' +
                            '<td><strong>Cidade:</strong> ' + ISNULL(cidade_destinatario, '') + '</td>' +
                            '<td><strong>UF:</strong> ' + ISNULL(uf_destinatario, '') + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '<td><strong>CEP:</strong> ' + ISNULL(cep_emitente, '') + '</td>' +
                            '<td><strong>CPF/CNPJ:</strong> ' + ISNULL(cnpj_emitente, '') + '</td>' +
                            '<td><strong>CEP:</strong> ' + ISNULL(cep_destinatario, '') + '</td>' +
                            '<td><strong>CPF/CNPJ:</strong> ' + ISNULL(doc_destinatario, '') + '</td>' +
                        '</tr>' +
                    '</table>' +
                    '<div class="subtitulo">IDENTIFICAÇÃO DOS BENS</div>' +
                    '<table class="tabela itens">' +
                        '<thead>' +
                            '<tr>' +
                                '<th style="width:10%;">ITEM</th>' +
                                '<th style="width:55%;">CONTEÚDO</th>' +
                                '<th style="width:15%;">QUANT.</th>' +
                                '<th style="width:20%;">VALOR</th>' +
                            '</tr>' +
                        '</thead>' +
                        '<tbody>' + ISNULL(itens_html, '<tr><td colspan="4">Nenhum item encontrado</td></tr>') + '</tbody>' +
                        '<tr class="totais">' +
                            '<td colspan="2" style="text-align:right;">TOTAIS</td>' +
                            '<td style="text-align:center;">' + CONVERT(NVARCHAR(30), qt_total) + '</td>' +
                            '<td style="text-align:right;">' + CONVERT(NVARCHAR(30), vl_total) + '</td>' +
                        '</tr>' +
                        '<tr class="peso-row">' +
                            '<td colspan="4"><strong>PESO TOTAL (kg):</strong> ' + ISNULL(CONVERT(NVARCHAR(30), peso_total), 'TODO: informar peso total (kg) via coluna da view vw_nfe_produto_servico_nota_fiscal_api') + '</td>' +
                        '</tr>' +
                    '</table>' +
                    '<div class="declaracao-bloco">' +
                        '<div class="declaracao-titulo">DECLARAÇÃO</div>' +
                        '<div>' +
                            'Declaro que não me enquadro no conceito de contribuinte previsto no art. 4º da Lei Complementar nº 87/1996, ' +
                            'uma vez que não realizo, com habitualidade ou em volume que caracterize intuito comercial, operações de circulação de mercadoria, ' +
                            'ainda que se iniciem no exterior, ou estou dispensado da emissão da nota fiscal por força da legislação tributária vigente, ' +
                            'responsabilizando-me, nos termos da lei e a quem de direito, por informações inverídicas.<br/>' +
                            'Declaro que não envio objeto que ponha em risco o transporte aéreo, nem objeto proibido no fluxo postal, ' +
                            'assumindo responsabilidade pela informação prestada, e ciente de que o descumprimento pode configurar crime, ' +
                            'conforme artigo 261 do Código Penal Brasileiro.<br/>' +
                            'Declaro, ainda, estar ciente da lista de proibições e restrições, disponível no site dos Correios: ' +
                            '<a href=\"https://www.correios.com.br/enviar/proibicoes-e-restricoes/proibicoes-e-restricoes\" target=\"_blank\">https://www.correios.com.br/enviar/proibicoes-e-restricoes/proibicoes-e-restricoes</a>.' +
                        '</div>' +
                        '<table class="assinatura">' +
                            '<tr>' +
                                '<td style="border:0;">______/______/______ de ________________________ de ________/______/______</td>' +
                            '</tr>' +
                            '<tr>' +
                                '<td>Assinatura do Declarante/Remetente</td>' +
                            '</tr>' +
                        '</table>' +
                    '</div>' +
                    '<div class="observacao">' +
                        'OBSERVAÇÃO:<br/><span class="observacao-texto">Constitui crime contra a ordem tributária suprimir ou reduzir tributo, ou contribuição social e qualquer acessório (Lei 8.137/90 Art. 1º, V).</span>' +
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
--use egissql_springs
--go
--qt_peso_bruto_nota_saida
--select top 10 * from nota_saida order by dt_nota_saida desc

--exec pr_egis_declaracao_conteudo '[{"cd_nota_saida": 13706 }]'
