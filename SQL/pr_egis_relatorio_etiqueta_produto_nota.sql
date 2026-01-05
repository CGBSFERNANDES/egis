IF EXISTS (SELECT name 
           FROM   sysobjects 
           WHERE  name = N'pr_egis_relatorio_etiqueta_produto_nota' 
           AND    type = 'P')
    DROP PROCEDURE pr_egis_relatorio_etiqueta_produto_nota
GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_etiqueta_produto_nota
-------------------------------------------------------------------------------
--pr_egis_relatorio_etiqueta_produto_nota
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2026
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2016
--
--Autor(es)        : ChatGPT (OpenAI) 
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório 418 - Etiqueta de Produto da Nota
--                   Gera HTML (RelatorioHTML) pronto para impressão de etiquetas
--                   no formato 10cm x 15cm (ajustável via JSON).
--
--Data             : 10.02.2026
--Alteração        : 
--
--Observações      : 
--  - Entrada única @json: [{"cd_nota_saida": <int>, "qt_copia": <int>, 
--                           "largura_cm": <decimal opcional>, 
--                           "altura_cm": <decimal opcional>}]
--  - Utiliza vw_nfe_produto_servico_nota_fiscal_api para compor os dados.
--  - Retorna sempre a coluna RelatorioHTML.
------------------------------------------------------------------------------ 
CREATE PROCEDURE pr_egis_relatorio_etiqueta_produto_nota
@json NVARCHAR(MAX) = N'' -- Parâmetro único de entrada em JSON
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        ------------------------------------------------------------------------------
        -- 1. Validação e normalização do JSON de entrada
        ------------------------------------------------------------------------------
        IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON inválido ou vazio em @json.', 1;

        -- Permite receber objeto único e normaliza para array
        IF JSON_VALUE(@json, '$[0]') IS NULL AND JSON_VALUE(@json, '$.cd_nota_saida') IS NOT NULL
            SET @json = N'[' + @json + N']';

        ------------------------------------------------------------------------------
        -- 2. Extração dos parâmetros para tabela temporária
        ------------------------------------------------------------------------------
        DECLARE @Parametros TABLE
        (
            cd_nota_saida INT          NOT NULL,
            qt_copia      INT          NULL,
            largura_cm    DECIMAL(10,2) NULL,
            altura_cm     DECIMAL(10,2) NULL
        );

        INSERT INTO @Parametros (cd_nota_saida, qt_copia, largura_cm, altura_cm)
        SELECT 
            cd_nota_saida,
            qt_copia,
            largura_cm,
            altura_cm
        FROM OPENJSON(@json)
        WITH
        (
            cd_nota_saida INT          '$.cd_nota_saida',
            qt_copia      INT          '$.qt_copia',
            largura_cm    DECIMAL(10,2) '$.largura_cm',
            altura_cm     DECIMAL(10,2) '$.altura_cm'
        );

        IF NOT EXISTS (SELECT 1 FROM @Parametros)
            THROW 50002, 'Nenhum parâmetro de nota informado em @json.', 1;

        -- Ajusta quantidade de cópias e garante nota obrigatória
        UPDATE p
           SET qt_copia = CASE WHEN ISNULL(qt_copia, 0) <= 0 THEN 1 ELSE qt_copia END
        FROM @Parametros p;

        ------------------------------------------------------------------------------
        -- 3. Configuração de tamanho de etiqueta (padrão 10cm x 15cm)
        ------------------------------------------------------------------------------
        DECLARE @largura_cm DECIMAL(10,2) = 10.00;
        DECLARE @altura_cm  DECIMAL(10,2) = 15.00;

        SELECT 
            @largura_cm = ISNULL(MAX(NULLIF(largura_cm, 0)), @largura_cm),
            @altura_cm  = ISNULL(MAX(NULLIF(altura_cm, 0)),  @altura_cm)
        FROM @Parametros;

        ------------------------------------------------------------------------------
        -- 4. Geração de números para replicar cópias (sem cursor)
        ------------------------------------------------------------------------------
        ;WITH Tally AS
        (
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
            FROM sys.all_objects -- suficiente para volumes elevados
        ),
        Copias AS
        (
            SELECT 
                p.cd_nota_saida,
                p.qt_copia,
                t.n AS cd_copia
            FROM @Parametros p
            JOIN Tally t 
              ON t.n <= p.qt_copia
        ),
        Base AS
        (
            SELECT 
                c.cd_nota_saida,
                c.cd_copia,
                v.cd_item_nota_saida,
                ISNULL(v.nItem, 0)                         AS nItem,
                ISNULL(v.cProd, '')                        AS cProd,
                ISNULL(v.xprod, '')                        AS xProd,
                ISNULL(v.cEan, '')                         AS cEan,
                ISNULL(v.cEanTrib, '')                     AS cEanTrib,
                ISNULL(v.qCom, '0.000')                    AS qCom,
                ISNULL(v.uCom, '')                         AS uCom,
                ISNULL(v.vUnCom, '0.000000')               AS vUnCom,
                ISNULL(v.vProd, '0.00')                    AS vProd,
                ISNULL(CONVERT(VARCHAR(10), v.dt_nota_saida, 103), '') AS dt_nota_saida,
                ROW_NUMBER() OVER (ORDER BY c.cd_nota_saida, v.nItem, c.cd_copia) AS rn
            FROM Copias c
            INNER JOIN vw_nfe_produto_servico_nota_fiscal_api v WITH (NOLOCK)
                    ON v.cd_nota_saida = c.cd_nota_saida
        )
        ------------------------------------------------------------------------------
        -- 5. Validação de existência de dados
        ------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1 FROM Base)
            THROW 50003, 'Nenhum item de produto encontrado para as notas informadas.', 1;

        ------------------------------------------------------------------------------
        -- 6. Montagem do HTML em padrão RelatorioHTML
        ------------------------------------------------------------------------------
        DECLARE @html  NVARCHAR(MAX) = N'';
        DECLARE @style NVARCHAR(MAX) = 
N'<style>
    body { font-family: ''Segoe UI'', Arial, sans-serif; color: #222; margin: 0; padding: 0; }
    .labels { display: flex; flex-wrap: wrap; gap: 8px; }
    .label { width: ' + CONVERT(VARCHAR(20), @largura_cm) + N'cm; height: ' + CONVERT(VARCHAR(20), @altura_cm) + N'cm; border: 1px solid #444; padding: 10px; box-sizing: border-box; position: relative; }
    .label__header { font-size: 12px; font-weight: 600; margin-bottom: 6px; display: flex; justify-content: space-between; }
    .label__title { font-size: 15px; font-weight: 700; margin-bottom: 6px; line-height: 1.2; }
    .label__code { font-size: 13px; margin-bottom: 4px; }
    .label__ean { font-size: 12px; margin-bottom: 4px; }
    .label__metrics { font-size: 12px; margin-bottom: 4px; }
    .label__footer { position: absolute; bottom: 6px; left: 10px; right: 10px; font-size: 11px; color: #444; display: flex; justify-content: space-between; }
    .barcode-text { font-size: 14px; letter-spacing: 2px; font-weight: 600; margin-top: 2px; }
    .page-break { page-break-after: always; }
</style>';

        SET @html = @style + N'<div class="labels">';

        -- Concatenação via FOR XML para compatibilidade com SQL Server 2016
        SET @html = @html +
        (
            SELECT
                '<div class="label">' +
                    '<div class="label__header">' +
                        '<span>Nota: '  + CONVERT(VARCHAR(20), b.cd_nota_saida) + '</span>' +
                        '<span>Cópia: ' + CONVERT(VARCHAR(10), b.cd_copia) + '</span>' +
                    '</div>' +
                    '<div class="label__title">' + b.xProd + '</div>' +
                    '<div class="label__code">Código: ' + b.cProd + '</div>' +
                    '<div class="label__ean">EAN: ' + b.cEan + '</div>' +
                    CASE WHEN b.cEanTrib <> '' AND b.cEanTrib <> b.cEan 
                         THEN '<div class="label__ean">EAN Trib.: ' + b.cEanTrib + '</div>'
                         ELSE '' END +
                    '<div class="barcode-text">' + b.cEan + '</div>' +
                    '<div class="label__metrics">Qtd.: ' + b.qCom + ' ' + b.uCom + ' | Vlr. Unit.: ' + b.vUnCom + '</div>' +
                    '<div class="label__metrics">Valor Item: ' + b.vProd + '</div>' +
                    '<div class="label__footer">' +
                        '<span>Item: ' + CONVERT(VARCHAR(10), b.nItem) + '</span>' +
                        '<span>Data: ' + b.dt_nota_saida + '</span>' +
                    '</div>' +
                '</div>'
            FROM Base b
            ORDER BY b.rn
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)');

        SET @html = @html + N'</div>';

        SELECT ISNULL(@html, N'') AS RelatorioHTML;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50010, @ErrorMessage, 1;
    END CATCH;
END;
GO

