IF OBJECT_ID('dbo.pr_egis_etiqueta_volume_nota_v2', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_etiqueta_volume_nota_v2;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_etiqueta_volume_nota_v2
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-01-XX
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : ChatGPT (OpenAI)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório 425 - Etiqueta de Volume (Nota Fiscal)
                     - Gera HTML (RelatorioHTML) no layout solicitado (faixas e separações).
                     - Uma etiqueta por volume, com o código de barras (texto) do
                       cd_identificacao_nota_saida.

  Parâmetro único de entrada (JSON):
    @json NVARCHAR(MAX)  --> [{"cd_nota_saida": <int>}]

  Requisitos Técnicos:
    - SET NOCOUNT ON
    - TRY...CATCH
    - Sem cursor (set-based)
    - Compatível com SQL Server 2016
    - Código comentado

  Fontes de dados de leitura:
    - vw_nfe_emitente_nota_fiscal (emitente)
    - vw_nfe_identificacao_nota_fiscal (identificação da nota)
    - vw_nfe_destintario_nota_fiscal (destinatário)
    - vw_nfe_transporte_nota_fiscal (transporte/volumes)
    - egisadmin.dbo.empresa (dados da empresa)
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_etiqueta_volume_nota_v2
    @json NVARCHAR(MAX) -- Parâmetro único vindo do front-end
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          1) Normaliza e valida JSON de entrada (aceita objeto ou array)
        -----------------------------------------------------------------------------------------*/
        DECLARE @jsonNormalized NVARCHAR(MAX) = LTRIM(RTRIM(ISNULL(@json, N'')));

        IF @jsonNormalized = N''
            SET @jsonNormalized = N'[{}]';

        IF ISJSON(@jsonNormalized) = 0
            THROW 50001, 'JSON de entrada inválido ou mal formatado.', 1;

        -- Aceita objeto isolado e converte para array
        --IF JSON_VALUE(@jsonNormalized, '$[0]') IS NULL
        --    SET @jsonNormalized = CONCAT('[', @jsonNormalized, ']');

        /*-----------------------------------------------------------------------------------------
          2) Carrega parâmetros em tabela (sem cursor)
        -----------------------------------------------------------------------------------------*/
        DECLARE @Parametros TABLE
        (
            cd_nota_saida INT NULL
        );

        INSERT INTO @Parametros (cd_nota_saida)
        SELECT
            TRY_CAST(j.cd_nota_saida AS INT) AS cd_nota_saida
        FROM OPENJSON(@jsonNormalized)
        WITH (
            cd_nota_saida INT '$.cd_nota_saida'
        ) AS j;

        IF NOT EXISTS (SELECT 1 FROM @Parametros)
            THROW 50002, 'Nenhum parâmetro informado em @json.', 1;

        IF EXISTS (SELECT 1 FROM @Parametros WHERE cd_nota_saida IS NULL)
            THROW 50003, 'Parâmetro cd_nota_saida é obrigatório.', 1;

        /*-----------------------------------------------------------------------------------------
          3) Carrega dados principais da nota/empresa (materializado para validar fora do CTE)
        -----------------------------------------------------------------------------------------*/
        DECLARE @Volumes TABLE
        (
            cd_nota_saida INT NULL,
            cd_identificacao_nota_saida VARCHAR(60) NULL,
            nr_nota VARCHAR(20) NULL,
            nr_serie VARCHAR(10) NULL,
            nm_emitente VARCHAR(120) NULL,
            endereco_emitente VARCHAR(200) NULL,
            cidade_emitente VARCHAR(100) NULL,
            uf_emitente VARCHAR(10) NULL,
            cep_emitente VARCHAR(15) NULL,
            nm_destinatario VARCHAR(120) NULL,
            endereco_destinatario VARCHAR(200) NULL,
            cidade_destinatario VARCHAR(100) NULL,
            uf_destinatario VARCHAR(10) NULL,
            cep_destinatario VARCHAR(15) NULL,
            nm_transportadora VARCHAR(120) NULL,
            endereco_transportadora VARCHAR(200) NULL,
            cidade_transportadora VARCHAR(100) NULL,
            uf_transportadora VARCHAR(10) NULL,
            qt_volume INT NULL,
            qt_volume_normalizado INT NOT NULL,
            nr_volume INT NOT NULL
        );

        ;WITH Base AS
        (
            SELECT
                p.cd_nota_saida,
                ident.cd_identificacao_nota_saida,
                ident.nNF AS nr_nota,
                ident.serie AS nr_serie,
                emit.xNome AS nm_emitente,
                emit.xLgr AS endereco_emitente,
                emit.xMun AS cidade_emitente,
                emit.UF AS uf_emitente,
                emit.CEP AS cep_emitente,
                dest.xNome AS nm_destinatario,
                dest.xLgr AS endereco_destinatario,
                dest.xMun AS cidade_destinatario,
                dest.UF AS uf_destinatario,
                dest.CEP AS cep_destinatario,
                transp.xNome AS nm_transportadora,
                transp.xEnder AS endereco_transportadora,
                transp.xMun AS cidade_transportadora,
                transp.UF AS uf_transportadora,
                TRY_CAST(transp.qVol AS INT) AS qt_volume
            FROM @Parametros AS p
            OUTER APPLY (
                SELECT TOP (1)
                    v.cd_identificacao_nota_saida,
                    v.nNF,
                    v.serie
                FROM vw_nfe_identificacao_nota_fiscal AS v
                WHERE v.cd_nota_saida = p.cd_nota_saida
                ORDER BY v.cd_identificacao_nota_saida
            ) AS ident
            OUTER APPLY (
                SELECT TOP (1)
                    v.xNome,
                    v.xLgr,
                    v.xMun,
                    v.UF,
                    v.CEP
                FROM vw_nfe_emitente_nota_fiscal AS v
                WHERE v.cd_nota_saida = p.cd_nota_saida
                ORDER BY v.cd_identificacao_nota_saida
            ) AS emit
            OUTER APPLY (
                SELECT TOP (1)
                    d.xNome,
                    d.xLgr,
                    d.xMun,
                    d.UF,
                    d.CEP
                FROM vw_nfe_destintario_nota_fiscal AS d
                WHERE d.cd_nota_saida = p.cd_nota_saida
                ORDER BY d.cd_identificacao_nota_saida
            ) AS dest
            OUTER APPLY (
                SELECT TOP (1)
                    t.xNome,
                    t.xEnder,
                    t.xMun,
                    t.UF,
                    t.qVol
                FROM vw_nfe_transporte_nota_fiscal AS t
                WHERE t.cd_nota_saida = p.cd_nota_saida
                ORDER BY t.cd_identificacao_nota_saida
            ) AS transp
        ),
        Tally AS
        (
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
            FROM sys.all_objects
        )
        INSERT INTO @Volumes (
            cd_nota_saida,
            cd_identificacao_nota_saida,
            nr_nota,
            nr_serie,
            nm_emitente,
            endereco_emitente,
            cidade_emitente,
            uf_emitente,
            cep_emitente,
            nm_destinatario,
            endereco_destinatario,
            cidade_destinatario,
            uf_destinatario,
            cep_destinatario,
            nm_transportadora,
            endereco_transportadora,
            cidade_transportadora,
            uf_transportadora,
            qt_volume,
            qt_volume_normalizado,
            nr_volume
        )
        SELECT
            b.cd_nota_saida,
            b.cd_identificacao_nota_saida,
            b.nr_nota,
            b.nr_serie,
            b.nm_emitente,
            b.endereco_emitente,
            b.cidade_emitente,
            b.uf_emitente,
            b.cep_emitente,
            b.nm_destinatario,
            b.endereco_destinatario,
            b.cidade_destinatario,
            b.uf_destinatario,
            b.cep_destinatario,
            b.nm_transportadora,
            b.endereco_transportadora,
            b.cidade_transportadora,
            b.uf_transportadora,
            b.qt_volume,
            CASE WHEN ISNULL(b.qt_volume, 0) <= 0 THEN 1 ELSE b.qt_volume END AS qt_volume_normalizado,
            t.n AS nr_volume
        FROM Base AS b
        JOIN Tally AS t
          ON t.n <= CASE WHEN ISNULL(b.qt_volume, 0) <= 0 THEN 1 ELSE b.qt_volume END;

        /*-----------------------------------------------------------------------------------------
          4) Validação de existência de dados
        -----------------------------------------------------------------------------------------*/
        IF NOT EXISTS (SELECT 1 FROM @Volumes)
            THROW 50004, 'Nenhum dado encontrado para a nota informada.', 1;

        /*-----------------------------------------------------------------------------------------
          5) Monta HTML de saída (RelatorioHTML) no layout solicitado
        -----------------------------------------------------------------------------------------*/
        DECLARE @html NVARCHAR(MAX) = N'';
        DECLARE @style NVARCHAR(MAX) =
N'<style>
    body { font-family: ''Segoe UI'', Arial, sans-serif; color: #222; margin: 0; padding: 0; }
    .label { border: 1px solid #444; margin-bottom: 8px; }
    .row { display: flex; border-bottom: 1px solid #444; }
    .row:last-child { border-bottom: 0; }
    .cell { padding: 6px 8px; font-size: 12px; }
    .cell--grow { flex: 1; }
    .cell--barcode { min-width: 180px; text-align: center; border-left: 1px solid #444; }
    .barcode-text { font-family: ''Courier New'', monospace; font-size: 14px; letter-spacing: 2px; font-weight: 600; }
    .label-title { font-weight: 700; }
    .row-footer { display: flex; align-items: center; }
    .footer-box { padding: 6px 8px; border-right: 1px solid #444; font-weight: 600; }
    .footer-box:last-child { border-right: 0; }
    .footer-grow { flex: 1; }
</style>';

        SET @html = @style;

        SET @html = @html +
        (
            SELECT
                '<div class="label">' +
                    '<div class="row">' +
                        '<div class="cell cell--grow">' +
                            '<div class="label-title">' + ISNULL(v.nm_emitente, '') + '</div>' +
                            '<div>' + ISNULL(v.endereco_emitente, '') + '</div>' +
                            '<div>' + ISNULL(v.cidade_emitente, '') + ' / ' + ISNULL(v.uf_emitente, '') + ' CEP ' + ISNULL(v.cep_emitente, '') + '</div>' +
                        '</div>' +
                        '<div class="cell cell--barcode">' +
                            '<div class="barcode-text">*' + ISNULL(v.cd_identificacao_nota_saida, '') + '*</div>' +
                            '<div>' + ISNULL(v.cd_identificacao_nota_saida, '') + '</div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="row">' +
                        '<div class="cell"><strong>Cliente</strong></div>' +
                        '<div class="cell cell--grow">' + ISNULL(v.nm_destinatario, '') + '</div>' +
                    '</div>' +
                    '<div class="row">' +
                        '<div class="cell"><strong>Endereço</strong></div>' +
                        '<div class="cell cell--grow">' + ISNULL(v.endereco_destinatario, '') + '</div>' +
                    '</div>' +
                    '<div class="row">' +
                        '<div class="cell"><strong>CEP / Cidade / UF</strong></div>' +
                        '<div class="cell cell--grow">' + ISNULL(v.cep_destinatario, '') + ' ' + ISNULL(v.cidade_destinatario, '') + ' / ' + ISNULL(v.uf_destinatario, '') + '</div>' +
                    '</div>' +
                    '<div class="row">' +
                        '<div class="cell"><strong>Transportadora</strong></div>' +
                        '<div class="cell cell--grow">' + ISNULL(v.nm_transportadora, '') + '</div>' +
                    '</div>' +
                    '<div class="row">' +
                        '<div class="cell"><strong>Endereço</strong></div>' +
                        '<div class="cell cell--grow">' + ISNULL(v.endereco_transportadora, '') + '</div>' +
                    '</div>' +
                    '<div class="row">' +
                        '<div class="cell"><strong>Cidade / UF</strong></div>' +
                        '<div class="cell cell--grow">' + ISNULL(v.cidade_transportadora, '') + ' / ' + ISNULL(v.uf_transportadora, '') + '</div>' +
                    '</div>' +
                    '<div class="row row-footer">' +
                        '<div class="footer-box">NFe</div>' +
                        '<div class="footer-box">' + ISNULL(CONVERT(VARCHAR(20), v.nr_nota), '') + '</div>' +
                        '<div class="footer-box">Volumes</div>' +
                        '<div class="footer-box">' + RIGHT('000' + CONVERT(VARCHAR(10), v.nr_volume), 3) + ' / ' + RIGHT('000' + CONVERT(VARCHAR(10), v.qt_volume_normalizado), 3) + '</div>' +
                        '<div class="footer-box footer-grow">1=Destinatário</div>' +
                    '</div>' +
                '</div>'
            FROM @Volumes AS v
            ORDER BY v.cd_nota_saida, v.nr_volume
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)');

        /*-----------------------------------------------------------------------------------------
          6) Retorno do HTML
        -----------------------------------------------------------------------------------------*/
        SELECT ISNULL(@html, N'') AS RelatorioHTML;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50010, @ErrorMessage, 1;
    END CATCH;
END;
GO


exec pr_egis_etiqueta_volume_nota_v2 '[{"cd_nota_saida": 553}]'