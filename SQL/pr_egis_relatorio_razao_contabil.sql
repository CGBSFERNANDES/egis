IF OBJECT_ID('dbo.pr_egis_relatorio_razao_contabil', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_razao_contabil;
GO

/*
-------------------------------------------------------------------------------
-- pr_egis_relatorio_razao_contabil
-------------------------------------------------------------------------------
-- GBS Global Business Solution Ltda                                        2026
-------------------------------------------------------------------------------
-- Stored Procedure : Microsoft SQL Server 2016
-- Autor(es)        : Codex (assistente)
-- Objetivo         : Gerar HTML do Relatório de Razão Contábil (cd_relatorio = 409)
-- Requisitos       :
--   * Apenas um parâmetro de entrada (@json)
--   * SET NOCOUNT ON
--   * TRY/CATCH com tratamento padronizado
--   * Sem cursores nesta procedure
--   * Performance voltada para grandes volumes
-- Referência       : Usa a pr_razao_contabil para recuperar os lançamentos
-------------------------------------------------------------------------------
*/
CREATE PROCEDURE dbo.pr_egis_relatorio_razao_contabil
    @json NVARCHAR(MAX) = NULL -- JSON no formato [{"dt_inicial":"YYYY-MM-DD","dt_final":"YYYY-MM-DD"}]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -----------------------------------------------------------------------
        -- 1) Declaração e defaults seguros
        -----------------------------------------------------------------------
        DECLARE
            @cd_relatorio        INT           = 409,
            @cd_empresa          INT           = NULL,
            @cd_usuario          INT           = NULL,
            @dt_inicial          DATE          = NULL,
            @dt_final            DATE          = NULL,
            @dt_final_inclusivo  DATETIME      = NULL,
            @ic_parametro        INT           = 1,      -- mesmo contrato da pr_razao_contabil
            @ic_ordem            CHAR(1)       = 'C',    -- C = Classificação (default do relatório legado)
            @ic_sem_movimento    CHAR(1)       = 'N',
            @cd_conta_inicial    INT           = 0,
            @cd_conta_final      INT           = 0;

        DECLARE
            @titulo              VARCHAR(200)  = 'Razão Contábil',
            @nm_titulo_relatorio VARCHAR(200)  = NULL,
            @ds_relatorio        VARCHAR(8000) = '',
            @logo                VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
            @nm_fantasia_empresa VARCHAR(200)  = '',
            @nm_endereco_empresa VARCHAR(200)  = '',
            @cd_numero_endereco  VARCHAR(20)   = '',
            @cd_cep_empresa      VARCHAR(20)   = '',
            @nm_cidade           VARCHAR(200)  = '',
            @sg_estado           VARCHAR(10)   = '',
            @cd_telefone_empresa VARCHAR(200)  = '',
            @nm_email_internet   VARCHAR(200)  = '',
            @nm_pais             VARCHAR(20)   = '',
            @cor_empresa         VARCHAR(20)   = '#1976D2',
            @data_hora_atual     VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

        -----------------------------------------------------------------------
        -- 2) Normaliza o JSON recebido (aceita objeto ou array com 1 posição)
        -----------------------------------------------------------------------
        IF NULLIF(@json, N'') IS NOT NULL AND ISJSON(@json) = 1
        BEGIN
            IF JSON_VALUE(@json, '$[0]') IS NOT NULL
                SET @json = JSON_QUERY(@json, '$[0]');

            SELECT
                @cd_empresa       = COALESCE(@cd_empresa,       TRY_CAST(JSON_VALUE(@json, '$.cd_empresa')            AS INT)),
                @cd_usuario       = COALESCE(@cd_usuario,       TRY_CAST(JSON_VALUE(@json, '$.cd_usuario')            AS INT)),
                @dt_inicial       = COALESCE(@dt_inicial,       TRY_CAST(JSON_VALUE(@json, '$.dt_inicial')            AS DATE)),
                @dt_final         = COALESCE(@dt_final,         TRY_CAST(JSON_VALUE(@json, '$.dt_final')              AS DATE)),
                @ic_parametro     = COALESCE(@ic_parametro,     TRY_CAST(JSON_VALUE(@json, '$.ic_parametro')          AS INT)),
                @ic_ordem         = COALESCE(@ic_ordem,         NULLIF(JSON_VALUE(@json, '$.ic_ordem'),               '')),
                @ic_sem_movimento = COALESCE(@ic_sem_movimento, NULLIF(JSON_VALUE(@json, '$.ic_sem_movimento'),       '')),
                @cd_conta_inicial = COALESCE(@cd_conta_inicial, TRY_CAST(JSON_VALUE(@json, '$.cd_conta_reduzido')     AS INT)),
                @cd_conta_final   = COALESCE(@cd_conta_final,   TRY_CAST(JSON_VALUE(@json, '$.cd_conta_reduzido_final') AS INT));
        END

        -----------------------------------------------------------------------
        -- 3) Datas padrão: Parametro_Relatorio -> mês corrente
        -----------------------------------------------------------------------
        IF @cd_relatorio IS NOT NULL AND @cd_relatorio > 0
        BEGIN
            SELECT
                @dt_inicial = COALESCE(@dt_inicial, pr.dt_inicial),
                @dt_final   = COALESCE(@dt_final,   pr.dt_final)
            FROM Parametro_Relatorio AS pr WITH (NOLOCK)
            WHERE pr.cd_relatorio = @cd_relatorio
              AND (@cd_usuario IS NULL OR pr.cd_usuario_relatorio = @cd_usuario);
        END

        IF @dt_inicial IS NULL OR @dt_final IS NULL
        BEGIN
            SET @dt_inicial = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
            SET @dt_final   = EOMONTH(@dt_inicial);
        END

        SET @cd_empresa         = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa());
        SET @ic_ordem           = CASE WHEN @ic_ordem IN ('C', 'R', 'D', 'Q') THEN @ic_ordem ELSE 'C' END;
        SET @ic_sem_movimento   = CASE WHEN @ic_sem_movimento IN ('S', 'N') THEN @ic_sem_movimento ELSE 'N' END;
        SET @cd_conta_inicial   = ISNULL(@cd_conta_inicial, 0);
        SET @cd_conta_final     = ISNULL(@cd_conta_final,   0);
        SET @ic_parametro       = ISNULL(NULLIF(@ic_parametro, 0), 1);
        SET @dt_final_inclusivo = DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(@dt_final AS DATETIME)));

        -----------------------------------------------------------------------
        -- 4) Dados do relatório e empresa (para cabeçalho HTML)
        -----------------------------------------------------------------------
        SELECT
            @titulo              = ISNULL(r.nm_relatorio, @titulo),
            @nm_titulo_relatorio = NULLIF(r.nm_titulo_relatorio, ''),
            @ds_relatorio        = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.relatorio AS r WITH (NOLOCK)
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
        LEFT JOIN Cidade AS c  ON c.cd_cidade  = e.cd_cidade
        LEFT JOIN Estado AS es ON es.cd_estado = c.cd_estado
        LEFT JOIN Pais AS p    ON p.cd_pais    = es.cd_pais
        WHERE e.cd_empresa = @cd_empresa;

        -----------------------------------------------------------------------
        -- 5) Captura dos dados via pr_razao_contabil (sem cursores aqui)
        -----------------------------------------------------------------------
        CREATE TABLE #RazaoContabil (
            id_seq         INT IDENTITY(1, 1) PRIMARY KEY,
            Conta          INT,
            Reduzido       INT,
            Classificacao  VARCHAR(50),
            Nome           VARCHAR(40),
            DataLancamento DATETIME,
            NumLancamento  VARCHAR(18),
            Contrapartida  INT,
            Debito         DECIMAL(18, 2),
            Credito        DECIMAL(18, 2),
            Saldo          DECIMAL(18, 2),
            TipoSaldo      CHAR(1),
            CodHistorico   INT,
            Historico      VARCHAR(8000)
        );

        INSERT INTO #RazaoContabil
            (Conta, Reduzido, Classificacao, Nome, DataLancamento, NumLancamento, Contrapartida, Debito, Credito, Saldo, TipoSaldo, CodHistorico, Historico)
        EXEC dbo.pr_razao_contabil
            @ic_parametro         = @ic_parametro,
            @ic_ordem             = @ic_ordem,
            @ic_sem_movimento     = @ic_sem_movimento,
            @cd_empresa           = @cd_empresa,
            @dt_inicial_exercicio = @dt_inicial,
            @dt_final_exercicio   = @dt_final_inclusivo,
            @cd_conta_reduzido    = @cd_conta_inicial,
            @cd_conta_reduzido_final = @cd_conta_final;

        -----------------------------------------------------------------------
        -- 6) Totalizadores e linhas HTML do corpo
        -----------------------------------------------------------------------
        DECLARE
            @total_debito  DECIMAL(18, 2) = 0,
            @total_credito DECIMAL(18, 2) = 0,
            @saldo_liquido DECIMAL(18, 2) = 0,
            @html_rows     NVARCHAR(MAX) = N'',
            @html_table    NVARCHAR(MAX) = N'',
            @html_header   NVARCHAR(MAX) = N'',
            @html_footer   NVARCHAR(MAX) = N'',
            @html          NVARCHAR(MAX) = N'',
            @titulo_exibir VARCHAR(200)  = ISNULL(NULLIF(@nm_titulo_relatorio, ''), @titulo);

        SELECT
            @total_debito  = SUM(ISNULL(rc.Debito, 0)),
            @total_credito = SUM(ISNULL(rc.Credito, 0))
        FROM #RazaoContabil AS rc;

        SET @saldo_liquido = ISNULL(@total_debito, 0) - ISNULL(@total_credito, 0);

        SET @html_rows = (
            SELECT
                '<tr>' +
                '<td>' + CONVERT(CHAR(10), rc.DataLancamento, 103) + '</td>' +
                '<td>' + ISNULL(rc.NumLancamento, '') + '</td>' +
                '<td>' + ISNULL(rc.Classificacao, '') + '</td>' +
                '<td>' + ISNULL(CAST(rc.Reduzido AS VARCHAR(20)), '') + '</td>' +
                '<td>' + ISNULL(rc.Nome, '') + '</td>' +
                '<td>' + ISNULL(CAST(rc.Contrapartida AS VARCHAR(20)), '') + '</td>' +
                '<td>' + ISNULL(CAST(rc.CodHistorico AS VARCHAR(12)), '') + ' - ' + ISNULL(rc.Historico, '') + '</td>' +
                '<td style="text-align:right">' + FORMAT(ISNULL(rc.Debito, 0), 'N2') + '</td>' +
                '<td style="text-align:right">' + FORMAT(ISNULL(rc.Credito, 0), 'N2') + '</td>' +
                '<td style="text-align:right">' + FORMAT(ISNULL(rc.Saldo, 0), 'N2') + '</td>' +
                '<td>' + ISNULL(rc.TipoSaldo, '') + '</td>' +
                '</tr>'
            FROM #RazaoContabil AS rc
            ORDER BY rc.Classificacao, rc.DataLancamento, rc.NumLancamento, rc.id_seq
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)');

        SET @html_table =
            '<table>' +
            '  <thead>' +
            '    <tr>' +
            '      <th>Data</th>' +
            '      <th>Lançamento</th>' +
            '      <th>Classificação</th>' +
            '      <th>Reduzido</th>' +
            '      <th>Conta</th>' +
            '      <th>Contrapartida</th>' +
            '      <th>Histórico</th>' +
            '      <th>Débito</th>' +
            '      <th>Crédito</th>' +
            '      <th>Saldo</th>' +
            '      <th>Tipo</th>' +
            '    </tr>' +
            '  </thead>' +
            '  <tbody>' + ISNULL(@html_rows, '') + '</tbody>' +
            '  <tfoot>' +
            '    <tr>' +
            '      <td colspan="7" style="text-align:right"><strong>Totais</strong></td>' +
            '      <td style="text-align:right"><strong>' + FORMAT(ISNULL(@total_debito, 0), 'N2') + '</strong></td>' +
            '      <td style="text-align:right"><strong>' + FORMAT(ISNULL(@total_credito, 0), 'N2') + '</strong></td>' +
            '      <td style="text-align:right"><strong>' + FORMAT(ISNULL(@saldo_liquido, 0), 'N2') + '</strong></td>' +
            '      <td></td>' +
            '    </tr>' +
            '  </tfoot>' +
            '</table>';

        -----------------------------------------------------------------------
        -- 7) Cabeçalho e HTML final
        -----------------------------------------------------------------------
        SET @html_header =
            '<html>' +
            '<head>' +
            '  <meta charset="UTF-8">' +
            '  <title>' + ISNULL(@titulo_exibir, 'Relatório') + '</title>' +
            '  <style>' +
            '    body { font-family: Arial, sans-serif; color: #333; padding: 20px; }' +
            '    h1 { color: ' + @cor_empresa + '; }' +
            '    table { width: 100%; border-collapse: collapse; margin-top: 20px; }' +
            '    th, td { border: 1px solid #ddd; padding: 8px; font-size: 12px; }' +
            '    th { background-color: #f2f2f2; text-align: left; }' +
            '    tfoot td { background-color: #fafafa; font-weight: bold; }' +
            '  </style>' +
            '</head>' +
            '<body>' +
            '  <div style="display:flex; justify-content: space-between; align-items: center;">' +
            '    <div style="width:30%; padding-right:20px;"><img src="' + @logo + '" alt="Logo" style="max-width: 220px;"></div>' +
            '    <div style="width:70%; padding-left:10px;">' +
            '      <h1>' + ISNULL(@titulo_exibir, '') + '</h1>' +
            '      <p><strong>' + @nm_fantasia_empresa + '</strong></p>' +
            '      <p>' + @nm_endereco_empresa + ', ' + @cd_numero_endereco + ' - ' + @cd_cep_empresa + ' - ' + @nm_cidade + ' - ' + @sg_estado + ' - ' + @nm_pais + '</p>' +
            '      <p><strong>Fone: </strong>' + @cd_telefone_empresa + ' | <strong>Email: </strong>' + @nm_email_internet + '</p>' +
            '      <p><strong>Período: </strong>' + CONVERT(CHAR(10), @dt_inicial, 103) + ' a ' + CONVERT(CHAR(10), @dt_final, 103) + '</p>' +
            '    </div>' +
            '  </div>' +
            '  <div style="margin-top:10px;">' + ISNULL(@ds_relatorio, '') + '</div>' +
            '  <div style="text-align:right; font-size:11px; margin-top:10px;">Gerado em: ' + @data_hora_atual + '</div>';

        SET @html_footer = '  </body></html>';
        SET @html        = @html_header + @html_table + @html_footer;

        SELECT ISNULL(@html, '') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        DECLARE @erro NVARCHAR(2048) = FORMATMESSAGE(
            'pr_egis_relatorio_razao_contabil falhou: %s (linha %d)',
            ERROR_MESSAGE(),
            ERROR_LINE()
        );

        RAISERROR(@erro, 16, 1);
    END CATCH
END
GO
