IF OBJECT_ID('dbo.pr_egis_relatorio_critica_lancamento', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_critica_lancamento;
GO

/*
-------------------------------------------------------------------------------
-- pr_egis_relatorio_critica_lancamento
-------------------------------------------------------------------------------
-- GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
-- Stored Procedure : Microsoft SQL Server 2016
--                   Gera colunas solicitadas e monta a crítica de consistência
-- Autor(es)       : Codex (assistente)                                      
-- Data            : 2026-01-05
-- Requisitos      :
--   - SET NOCOUNT ON
--   - TRY/CATCH com THROW
--   - Sem cursor
--   - Performance para grandes volumes
-------------------------------------------------------------------------------
*/
CREATE PROCEDURE dbo.pr_egis_relatorio_critica_lancamento
    @cd_relatorio INT           = 407,        -- Código do relatório cadastrado em egisadmin.dbo.relatorio
    @json         NVARCHAR(MAX) = NULL        -- Parâmetros vindos do front-end (datas e filtros opcionais)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cd_empresa            INT          = NULL,
        @cd_usuario            INT          = NULL,
        @dt_inicial_exercicio  DATE         = NULL,
        @dt_final_exercicio    DATE         = NULL,
        @cd_lancamento_inicial INT          = NULL,
        @cd_lancamento_final   INT          = NULL,
        @cd_lote_inicial       INT          = NULL,
        @cd_lote_final         INT          = NULL,
        @nm_titulo_relatorio   VARCHAR(200) = NULL,
        @ds_relatorio          VARCHAR(8000) = '',
        @logo                  VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
        @nm_fantasia_empresa   VARCHAR(200)  = '',
        @nm_endereco_empresa   VARCHAR(200)  = '',
        @cd_numero_endereco    VARCHAR(20)   = '',
        @cd_cep_empresa        VARCHAR(20)   = '',
        @nm_cidade             VARCHAR(200)  = '',
        @sg_estado             VARCHAR(10)   = '',
        @cd_telefone_empresa   VARCHAR(200)  = '',
        @nm_email_internet     VARCHAR(200)  = '',
        @nm_pais               VARCHAR(20)   = '',
        @cor_empresa           VARCHAR(20)   = '#1976D2',
        @data_hora_atual       VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108),
        @html_rows             NVARCHAR(MAX) = '',
        @html_table            NVARCHAR(MAX) = '',
        @html_header           NVARCHAR(MAX) = '',
        @html_footer           NVARCHAR(MAX) = '',
        @html                  NVARCHAR(MAX) = '';

    BEGIN TRY
        /*
           1) Normaliza o JSON recebido
              - Aceita array ou objeto
              - Captura apenas campos usados no relatório
        */
        IF NULLIF(@json, N'') IS NOT NULL AND ISJSON(@json) = 1
        BEGIN
            IF JSON_VALUE(@json, '$[0]') IS NOT NULL
                SET @json = JSON_QUERY(@json, '$[0]');

            SELECT
                @cd_empresa            = COALESCE(cfg.cd_empresa, @cd_empresa),
                @cd_usuario            = COALESCE(cfg.cd_usuario, @cd_usuario),
                @dt_inicial_exercicio  = COALESCE(cfg.dt_inicial, @dt_inicial_exercicio),
                @dt_final_exercicio    = COALESCE(cfg.dt_final, @dt_final_exercicio),
                @cd_lancamento_inicial = COALESCE(cfg.cd_lancamento_inicial, @cd_lancamento_inicial),
                @cd_lancamento_final   = COALESCE(cfg.cd_lancamento_final, @cd_lancamento_final),
                @cd_lote_inicial       = COALESCE(cfg.cd_lote_inicial, @cd_lote_inicial),
                @cd_lote_final         = COALESCE(cfg.cd_lote_final, @cd_lote_final)
            FROM OPENJSON(@json) WITH (
                cd_empresa            INT  '$.cd_empresa',
                cd_usuario            INT  '$.cd_usuario',
                dt_inicial            DATE '$.dt_inicial',
                dt_final              DATE '$.dt_final',
                cd_lancamento_inicial INT  '$.cd_lancamento_inicial',
                cd_lancamento_final   INT  '$.cd_lancamento_final',
                cd_lote_inicial       INT  '$.cd_lote_inicial',
                cd_lote_final         INT  '$.cd_lote_final'
            ) cfg;
        END

        /*
           2) Recupera intervalo default do Parametro_Relatorio (quando existir)
              Mantém valores informados no JSON.
        */
        IF @cd_relatorio IS NOT NULL AND @cd_relatorio > 0
        BEGIN
            SELECT
                @dt_inicial_exercicio = COALESCE(@dt_inicial_exercicio, pr.dt_inicial),
                @dt_final_exercicio   = COALESCE(@dt_final_exercicio, pr.dt_final)
            FROM Parametro_Relatorio AS pr WITH (NOLOCK)
            WHERE pr.cd_relatorio = @cd_relatorio
              AND (@cd_usuario IS NULL OR pr.cd_usuario_relatorio = @cd_usuario);
        END

        /* 3) Defaults seguros para evitar varreduras desnecessárias */
        SET @cd_empresa = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa());
        SET @dt_inicial_exercicio = ISNULL(@dt_inicial_exercicio, DATEADD(DAY, -30, CAST(GETDATE() AS DATE)));
        SET @dt_final_exercicio   = ISNULL(@dt_final_exercicio, CAST(GETDATE() AS DATE));
        SET @cd_lancamento_inicial = ISNULL(@cd_lancamento_inicial, 0);
        SET @cd_lancamento_final   = ISNULL(@cd_lancamento_final, 2147483647);
        SET @cd_lote_inicial       = ISNULL(@cd_lote_inicial, 0);
        SET @cd_lote_final         = ISNULL(@cd_lote_final, 2147483647);

        /*
           4) Base do relatório: aplica filtros e monta flags de crítica
              - Critérios exigidos: falta valor, débito/crédito, sem histórico padrão, sem lote
              - Verifica equilíbrio débito x crédito por lançamento
        */
        ;WITH BaseLancamento AS (
            SELECT
                a.dt_lancamento_contabil,
                a.cd_lancamento_contabil,
                a.cd_reduzido_debito,
                a.cd_reduzido_credito,
                a.vl_lancamento_contabil,
                a.cd_historico_contabil,
                a.ds_historico_contabil,
                a.cd_lote,
                CAST(CASE WHEN ISNULL(a.vl_lancamento_contabil, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS ic_falta_valor,
                CAST(CASE WHEN ISNULL(a.cd_reduzido_debito, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS ic_falta_debito,
                CAST(CASE WHEN ISNULL(a.cd_reduzido_credito, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS ic_falta_credito,
                CAST(CASE WHEN ISNULL(a.cd_historico_contabil, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS ic_sem_historico,
                CAST(CASE WHEN ISNULL(a.cd_lote, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS ic_sem_lote,
                SUM(CASE WHEN ISNULL(a.cd_reduzido_debito, 0) > 0 THEN a.vl_lancamento_contabil ELSE 0 END)
                    OVER (PARTITION BY a.cd_empresa, a.cd_lancamento_contabil) AS vl_total_debito,
                SUM(CASE WHEN ISNULL(a.cd_reduzido_credito, 0) > 0 THEN a.vl_lancamento_contabil ELSE 0 END)
                    OVER (PARTITION BY a.cd_empresa, a.cd_lancamento_contabil) AS vl_total_credito
            FROM movimento_contabil AS a WITH (NOLOCK)
            WHERE a.cd_empresa = @cd_empresa
              AND a.dt_lancamento_contabil BETWEEN @dt_inicial_exercicio AND @dt_final_exercicio
              AND a.cd_lancamento_contabil BETWEEN @cd_lancamento_inicial AND @cd_lancamento_final
              AND a.cd_lote BETWEEN @cd_lote_inicial AND @cd_lote_final
        ),
        BaseCritica AS (
            SELECT
                b.dt_lancamento_contabil AS [Data],
                b.cd_lancamento_contabil AS Lancamento,
                b.cd_reduzido_debito     AS Debito,
                b.cd_reduzido_credito    AS Credito,
                b.vl_lancamento_contabil AS ValorLancamento,
                b.cd_historico_contabil  AS CodHis,
                b.ds_historico_contabil  AS Historico,
                b.cd_lote                AS Lote,
                LTRIM(STUFF(
                    CONCAT(
                        CASE WHEN b.ic_falta_valor    = 1 THEN '; Falta valor' ELSE '' END,
                        CASE WHEN b.ic_falta_debito   = 1 THEN '; Falta débito' ELSE '' END,
                        CASE WHEN b.ic_falta_credito  = 1 THEN '; Falta crédito' ELSE '' END,
                        CASE WHEN b.vl_total_debito <> b.vl_total_credito THEN '; Não fecha com crédito' ELSE '' END,
                        CASE WHEN b.ic_sem_historico  = 1 THEN '; Sem histórico padrão' ELSE '' END,
                        CASE WHEN b.ic_sem_lote       = 1 THEN '; Sem lote' ELSE '' END
                    ),
                    1,
                    2,
                    ''
                )) AS Critica
            FROM BaseLancamento AS b
        )
        SELECT
            *
        INTO #resultado
        FROM BaseCritica
        WHERE Critica IS NOT NULL AND LTRIM(RTRIM(Critica)) <> '';

        /* 5) Cabeçalho e informações da empresa para o HTML */
        SELECT
            @nm_titulo_relatorio = NULLIF(r.nm_titulo_relatorio, ''),
            @ds_relatorio        = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.relatorio AS r
        WHERE r.cd_relatorio = @cd_relatorio;

        SELECT TOP (1)
            @logo                = ISNULL('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, @logo),
            @cor_empresa         = ISNULL(e.nm_cor_empresa, @cor_empresa),
            @nm_fantasia_empresa = ISNULL(e.nm_fantasia_empresa, ''),
            @nm_endereco_empresa = ISNULL(e.nm_endereco_empresa, ''),
            @cd_numero_endereco  = LTRIM(RTRIM(ISNULL(e.cd_numero, ''))),
            @cd_cep_empresa      = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @nm_cidade           = ISNULL(c.nm_cidade, ''),
            @sg_estado           = ISNULL(es.sg_estado, ''),
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet   = ISNULL(e.nm_email_internet, ''),
            @nm_pais             = ISNULL(p.sg_pais, '')
        FROM Empresa AS e
        LEFT JOIN Cidade AS c   ON c.cd_cidade  = e.cd_cidade
        LEFT JOIN Estado AS es  ON es.cd_estado = c.cd_estado
        LEFT JOIN Pais   AS p   ON p.cd_pais    = es.cd_pais
        WHERE e.cd_empresa = @cd_empresa;

        /* 6) Montagem das linhas HTML (sem STRING_AGG para compatibilidade 2016) */
        SET @html_rows = (
            SELECT
                '<tr>' +
                '<td>' + CONVERT(CHAR(10), r.[Data], 103) + '</td>' +
                '<td>' + CAST(ISNULL(r.Lancamento, 0) AS VARCHAR(20)) + '</td>' +
                '<td>' + ISNULL(CAST(r.Debito AS VARCHAR(20)), '') + '</td>' +
                '<td>' + ISNULL(CAST(r.Credito AS VARCHAR(20)), '') + '</td>' +
                '<td style="text-align:right">' + FORMAT(ISNULL(r.ValorLancamento, 0), 'N2') + '</td>' +
                '<td>' + ISNULL(CAST(r.CodHis AS VARCHAR(20)), '') + '</td>' +
                '<td>' + ISNULL(r.Historico, '') + '</td>' +
                '<td>' + ISNULL(CAST(r.Lote AS VARCHAR(20)), '') + '</td>' +
                '<td>' + ISNULL(r.Critica, '') + '</td>' +
                '</tr>'
            FROM #resultado AS r
            ORDER BY r.[Data], r.Lancamento
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)');

        IF @html_rows IS NULL OR LTRIM(RTRIM(@html_rows)) = ''
        BEGIN
            SET @html_rows = '<tr><td colspan="9" style="text-align:center">Nenhuma crítica encontrada para o período informado.</td></tr>';
        END

        /* 7) Estrutura completa do HTML */
        DECLARE @titulo_exibir VARCHAR(200) = ISNULL(@nm_titulo_relatorio, 'Crítica do Lançamento Contábil');

        SET @html_table =
            '<table style="width:100%; border-collapse: collapse; margin-top: 15px;">' +
            '  <thead>' +
            '    <tr>' +
            '      <th style="border:1px solid #ddd; padding:8px; text-align:left; background:#f2f2f2;">Data</th>' +
            '      <th style="border:1px solid #ddd; padding:8px; text-align:left; background:#f2f2f2;">Lançamento</th>' +
            '      <th style="border:1px solid #ddd; padding:8px; text-align:left; background:#f2f2f2;">Débito</th>' +
            '      <th style="border:1px solid #ddd; padding:8px; text-align:left; background:#f2f2f2;">Crédito</th>' +
            '      <th style="border:1px solid #ddd; padding:8px; text-align:right; background:#f2f2f2;">Valor</th>' +
            '      <th style="border:1px solid #ddd; padding:8px; text-align:left; background:#f2f2f2;">Cod. Histórico</th>' +
            '      <th style="border:1px solid #ddd; padding:8px; text-align:left; background:#f2f2f2;">Histórico</th>' +
            '      <th style="border:1px solid #ddd; padding:8px; text-align:left; background:#f2f2f2;">Lote</th>' +
            '      <th style="border:1px solid #ddd; padding:8px; text-align:left; background:#f2f2f2;">Crítica</th>' +
            '    </tr>' +
            '  </thead>' +
            '  <tbody>' + ISNULL(@html_rows, '') + '</tbody>' +
            '</table>';

        SET @html_header =
            '<html>' +
            '<head>' +
            '  <meta charset=\"UTF-8\">' +
            '  <title>' + @titulo_exibir + '</title>' +
            '  <style>' +
            '    body { font-family: Arial, sans-serif; color: #333; padding: 20px; }' +
            '    h1 { color: ' + @cor_empresa + '; margin-bottom: 5px; }' +
            '    p { margin: 2px 0; }' +
            '  </style>' +
            '</head>' +
            '<body>' +
            '  <div style=\"display:flex; justify-content: space-between; align-items: center;\">' +
            '    <div style=\"width:30%; padding-right:20px;\"><img src=\"' + @logo + '\" alt=\"Logo\" style=\"max-width: 200px;\"></div>' +
            '    <div style=\"width:70%; padding-left:10px;\">' +
            '      <h1>' + @titulo_exibir + '</h1>' +
            '      <p><strong>' + @nm_fantasia_empresa + '</strong></p>' +
            '      <p>' + @nm_endereco_empresa + ', ' + @cd_numero_endereco + ' - ' + @cd_cep_empresa + ' - ' + @nm_cidade + '/' + @sg_estado + ' - ' + @nm_pais + '</p>' +
            '      <p><strong>Fone: </strong>' + @cd_telefone_empresa + ' | <strong>Email: </strong>' + @nm_email_internet + '</p>' +
            '      <p><strong>Período: </strong>' + CONVERT(CHAR(10), @dt_inicial_exercicio, 103) + ' a ' + CONVERT(CHAR(10), @dt_final_exercicio, 103) + '</p>' +
            '    </div>' +
            '  </div>' +
            '  <div style=\"margin-top:10px;\">' + ISNULL(@ds_relatorio, '') + '</div>' +
            '  <div style=\"text-align:right; font-size:11px; margin-top:10px;\">Gerado em: ' + @data_hora_atual + '</div>';

        SET @html_footer = '  </body></html>';
        SET @html        = @html_header + @html_table + @html_footer;

        SELECT ISNULL(@html, '') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        DECLARE @errMsg NVARCHAR(2048) = FORMATMESSAGE(
            'pr_egis_relatorio_critica_lancamento falhou: %s (linha %d)',
            ERROR_MESSAGE(),
            ERROR_LINE()
        );

        THROW ERROR_NUMBER(), @errMsg, ERROR_STATE();
    END CATCH
END
GO

--exec pr_egis_relatorio_critica_lancamento '[{"dt_inicial": "01/01/2023", "dt_final": "12/31/2023"}]'
