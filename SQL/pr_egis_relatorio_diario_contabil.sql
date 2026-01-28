IF EXISTS (SELECT name 
           FROM   sysobjects 
           WHERE  name = N'pr_egis_relatorio_diario_contabil' 
           AND    type = 'P')
    DROP PROCEDURE pr_egis_relatorio_diario_contabil;
GO

-------------------------------------------------------------------------------
-- sp_helptext pr_egis_relatorio_diario_contabil
-------------------------------------------------------------------------------
-- pr_egis_relatorio_diario_contabil
-------------------------------------------------------------------------------
-- GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
-- Stored Procedure : Microsoft SQL Server 2016
-- Autor(es)        : Codex
-- Banco de Dados   : Egissql - Banco do Cliente 
-- Objetivo         : Relatório HTML - Diário Contábil (cd_relatorio = 408)
-- Data             : 2025-02-06
-- Observações      :
--  * Utiliza o JSON recebido para datas e modo (simplificado/detalhado)
--  * Compatível com Engine de Relatórios padrão (pr_egis_relatorio_padrao)
--  * Código comentado, sem cursores, com foco em volumetria
-------------------------------------------------------------------------------
CREATE PROCEDURE dbo.pr_egis_relatorio_diario_contabil
    @cd_relatorio INT           = 408, -- Identificador do relatório
    @cd_parametro INT           = 0,   -- 1 = preview simplificado, 2 = preview detalhado, demais = HTML
    @json         NVARCHAR(MAX) = NULL -- JSON de entrada (array ou objeto)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -----------------------------------------------------------------------
        -- 1) Variáveis de trabalho
        -----------------------------------------------------------------------
        DECLARE
            @cd_empresa   INT           = 0,
            @cd_usuario   INT           = 0,
            @dt_inicial   DATE          = NULL,
            @dt_final     DATE          = NULL,
            @dt_limite    DATETIME      = NULL,
            @ic_parametro INT           = 2; -- 1 = Simplificado | 2 = Detalhado (padrão)

        DECLARE
            @titulo              VARCHAR(200)  = 'Diário Contábil',
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
        -- 2) Leitura do JSON (@json pode vir como array [ {..} ])
        -----------------------------------------------------------------------
        IF NULLIF(@json, N'') IS NOT NULL AND ISJSON(@json) = 1
        BEGIN
            IF JSON_VALUE(@json, '$[0]') IS NOT NULL
                SET @json = JSON_QUERY(@json, '$[0]');

            SELECT
                @cd_empresa   = COALESCE(@cd_empresa, TRY_CAST(JSON_VALUE(@json, '$.cd_empresa')   AS INT)),
                @cd_usuario   = COALESCE(@cd_usuario, TRY_CAST(JSON_VALUE(@json, '$.cd_usuario')   AS INT)),
                @dt_inicial   = COALESCE(@dt_inicial, TRY_CAST(JSON_VALUE(@json, '$.dt_inicial')   AS DATE)),
                @dt_final     = COALESCE(@dt_final,   TRY_CAST(JSON_VALUE(@json, '$.dt_final')     AS DATE)),
                @cd_parametro = COALESCE(NULLIF(@cd_parametro, 0), TRY_CAST(JSON_VALUE(@json, '$.cd_parametro') AS INT)),
                @ic_parametro = COALESCE(@ic_parametro, TRY_CAST(JSON_VALUE(@json, '$.ic_parametro') AS INT));
        END

        SET @cd_empresa = ISNULL(@cd_empresa, dbo.fn_empresa());
        IF @ic_parametro NOT IN (1, 2) SET @ic_parametro = 2;

        -----------------------------------------------------------------------
        -- 3) Datas: busca parametrização salva e fallback para mês corrente
        -----------------------------------------------------------------------
        IF (@dt_inicial IS NULL OR @dt_final IS NULL)
        BEGIN
            SELECT
                @dt_inicial = COALESCE(@dt_inicial, pr.dt_inicial),
                @dt_final   = COALESCE(@dt_final,   pr.dt_final)
            FROM Parametro_Relatorio pr
            WHERE pr.cd_relatorio = @cd_relatorio
              AND (ISNULL(@cd_usuario, 0) = 0 OR pr.cd_usuario = @cd_usuario);
        END

        IF @dt_inicial IS NULL OR @dt_final IS NULL
        BEGIN
            SET @dt_inicial = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
            SET @dt_final   = EOMONTH(@dt_inicial);
        END

        SET @dt_limite = DATEADD(DAY, 1, @dt_final); -- exclusão do limite superior para considerar o dia cheio

        -----------------------------------------------------------------------
        -- 4) Dados do relatório e da empresa (para o cabeçalho HTML)
        -----------------------------------------------------------------------
        SELECT
            @titulo              = ISNULL(r.nm_relatorio, @titulo),
            @nm_titulo_relatorio = NULLIF(r.nm_titulo_relatorio, ''),
            @ds_relatorio        = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.relatorio r
        WHERE r.cd_relatorio = @cd_relatorio;

        SELECT TOP (1)
            @logo                = ISNULL('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, 'logo_gbstec_sistema.jpg'),
            @cor_empresa         = ISNULL(e.nm_cor_empresa, '#1976D2'),
            @nm_fantasia_empresa = ISNULL(e.nm_fantasia_empresa, ''),
            @nm_endereco_empresa = ISNULL(e.nm_endereco_empresa, ''),
            @cd_numero_endereco  = LTRIM(RTRIM(ISNULL(e.cd_numero, ''))),
            @cd_cep_empresa      = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @nm_cidade           = ISNULL(c.nm_cidade, ''),
            @sg_estado           = ISNULL(es.sg_estado, ''),
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet   = ISNULL(e.nm_email_internet, ''),
            @nm_pais             = ISNULL(p.sg_pais, '')
        FROM Empresa e
        LEFT JOIN Cidade c   ON c.cd_cidade   = e.cd_cidade
        LEFT JOIN Estado es  ON es.cd_estado  = c.cd_estado
        LEFT JOIN Pais p     ON p.cd_pais     = es.cd_pais
        WHERE e.cd_empresa = @cd_empresa;

        -----------------------------------------------------------------------
        -- 5) Base de lançamentos (filtrada por empresa, período e lote ativo)
        -----------------------------------------------------------------------
        ;WITH base_mov AS (
            SELECT
                m.cd_empresa,
                m.cd_lote,
                m.cd_lancamento_contabil,
                m.dt_lancamento_contabil,
                ISNULL(m.cd_reduzido_debito, 0)     AS cd_reduzido_debito,
                ISNULL(m.cd_reduzido_credito, 0)    AS cd_reduzido_credito,
                ISNULL(m.vl_lancamento_contabil, 0) AS vl_lancamento_contabil,
                ISNULL(m.cd_historico_contabil, 0)  AS cd_historico_contabil,
                CAST(m.ds_historico_contabil AS NVARCHAR(MAX)) AS ds_historico_contabil,
                CONCAT(CAST(ISNULL(m.cd_lote, 0) AS VARCHAR(8)), '-', CAST(ISNULL(m.cd_lancamento_contabil, 0) AS VARCHAR(8))) AS Lancamento,
                ISNULL(lot.ic_ativa_lote, 'N') AS ic_ativa_lote
            FROM Movimento_contabil AS m
            OUTER APPLY (
                SELECT TOP (1) l.ic_ativa_lote
                FROM Lote_contabil l
                WHERE l.cd_lote = m.cd_lote
            ) AS lot
            WHERE m.cd_empresa = @cd_empresa
              AND m.dt_lancamento_contabil >= @dt_inicial
              AND m.dt_lancamento_contabil <  @dt_limite
        )
        -----------------------------------------------------------------------
        -- 6) Projeção simplificada e detalhada (sem cursores)
        -----------------------------------------------------------------------
        , base_filtrada AS (
            SELECT *
            FROM base_mov
            WHERE ic_ativa_lote <> 'N'
        ),
        simplificado AS (
            SELECT
                b.dt_lancamento_contabil AS Data,
                b.Lancamento,
                LEFT(ISNULL(pd.cd_mascara_conta, ''), 20) AS Debito,
                LEFT(ISNULL(pc.cd_mascara_conta, ''), 20) AS Credito,
                b.cd_historico_contabil                   AS CodHistorico,
                b.ds_historico_contabil                   AS Historico,
                b.vl_lancamento_contabil                  AS Valor
            FROM base_filtrada b
            LEFT JOIN Plano_conta pd ON pd.cd_empresa = b.cd_empresa AND pd.cd_conta_reduzido = b.cd_reduzido_debito
            LEFT JOIN Plano_conta pc ON pc.cd_empresa = b.cd_empresa AND pc.cd_conta_reduzido = b.cd_reduzido_credito
        ),
        detalhado_debito AS (
            SELECT
                LEFT(ISNULL(pd.nm_conta, ''), 40)        AS Conta,
                LEFT(ISNULL(pd.cd_mascara_conta, ''),20) AS Classificacao,
                b.cd_reduzido_debito                     AS Codigo,
                b.cd_reduzido_credito                    AS Contrapartida,
                LEFT(ISNULL(pc.cd_mascara_conta, ''),20) AS ClassifContra,
                b.dt_lancamento_contabil                 AS Data,
                b.Lancamento,
                b.cd_historico_contabil                  AS CodHistorico,
                b.ds_historico_contabil                  AS Historico,
                b.vl_lancamento_contabil                 AS Debito,
                CAST(0 AS DECIMAL(18, 2))                AS Credito
            FROM base_filtrada b
            INNER JOIN Plano_conta pd ON pd.cd_empresa = b.cd_empresa AND pd.cd_conta_reduzido = b.cd_reduzido_debito AND b.cd_reduzido_debito <> 0
            LEFT JOIN  Plano_conta pc ON pc.cd_empresa = b.cd_empresa AND pc.cd_conta_reduzido = b.cd_reduzido_credito
        ),
        detalhado_credito AS (
            SELECT
                LEFT(ISNULL(pc.nm_conta, ''), 40)        AS Conta,
                LEFT(ISNULL(pc.cd_mascara_conta, ''),20) AS Classificacao,
                b.cd_reduzido_credito                    AS Codigo,
                b.cd_reduzido_debito                     AS Contrapartida,
                LEFT(ISNULL(pd.cd_mascara_conta, ''),20) AS ClassifContra,
                b.dt_lancamento_contabil                 AS Data,
                b.Lancamento,
                b.cd_historico_contabil                  AS CodHistorico,
                b.ds_historico_contabil                  AS Historico,
                CAST(0 AS DECIMAL(18, 2))                AS Debito,
                b.vl_lancamento_contabil                 AS Credito
            FROM base_filtrada b
            INNER JOIN Plano_conta pc ON pc.cd_empresa = b.cd_empresa AND pc.cd_conta_reduzido = b.cd_reduzido_credito AND b.cd_reduzido_credito <> 0
            LEFT JOIN  Plano_conta pd ON pd.cd_empresa = b.cd_empresa AND pd.cd_conta_reduzido = b.cd_reduzido_debito
        )
        SELECT * INTO #DiarioSimplificado FROM simplificado;

        SELECT *
        INTO #Aux_Diario_Contabil
        FROM (
            SELECT * FROM detalhado_debito
            UNION ALL
            SELECT * FROM detalhado_credito
        ) AS d;

        -----------------------------------------------------------------------
        -- 7) Saídas "brutas" (úteis para debug/preview)
        -----------------------------------------------------------------------
        IF @cd_parametro = 1
        BEGIN
            SELECT *
            FROM #DiarioSimplificado
            ORDER BY Data, Lancamento;
            RETURN;
        END

        IF @cd_parametro = 2
        BEGIN
            SELECT *
            FROM #Aux_Diario_Contabil
            ORDER BY Data, Classificacao, Lancamento;
            RETURN;
        END

        -----------------------------------------------------------------------
        -- 8) Montagem do HTML (modo padrão)
        -----------------------------------------------------------------------
        DECLARE
            @html_header NVARCHAR(MAX) = N'',
            @html_table  NVARCHAR(MAX) = N'',
            @html_rows   NVARCHAR(MAX) = N'',
            @html_footer NVARCHAR(MAX) = N'',
            @html        NVARCHAR(MAX) = N'';

        DECLARE
            @total_debito   DECIMAL(18, 2) = 0,
            @total_credito  DECIMAL(18, 2) = 0,
            @total_valor    DECIMAL(18, 2) = 0,
            @titulo_exibir  VARCHAR(200)   = ISNULL(NULLIF(@nm_titulo_relatorio, ''), @titulo);

        SELECT @total_valor = SUM(Valor) FROM #DiarioSimplificado;
        SELECT @total_debito = SUM(Debito), @total_credito = SUM(Credito) FROM #Aux_Diario_Contabil;

        IF @ic_parametro = 1
        BEGIN
            SET @html_rows = (
                SELECT
                    '<tr>' +
                    '<td>' + CONVERT(CHAR(10), d.Data, 103) + '</td>' +
                    '<td>' + ISNULL(d.Lancamento, '') + '</td>' +
                    '<td>' + ISNULL(d.Debito, '') + '</td>' +
                    '<td>' + ISNULL(d.Credito, '') + '</td>' +
                    '<td>' + ISNULL(CAST(d.CodHistorico AS VARCHAR(12)), '') + '</td>' +
                    '<td>' + ISNULL(d.Historico, '') + '</td>' +
                    '<td style="text-align:right">' + FORMAT(d.Valor, 'N2') + '</td>' +
                    '</tr>'
                FROM #DiarioSimplificado AS d
                ORDER BY d.Data, d.Lancamento
                FOR XML PATH(''), TYPE
            ).value('.', 'nvarchar(max)');

            SET @html_table =
                '<table>' +
                '<thead>' +
                '  <tr>' +
                '    <th>Data</th>' +
                '    <th>Lançamento</th>' +
                '    <th>Débito</th>' +
                '    <th>Crédito</th>' +
                '    <th>Cód. Histórico</th>' +
                '    <th>Histórico</th>' +
                '    <th>Valor</th>' +
                '  </tr>' +
                '</thead>' +
                '<tbody>' + ISNULL(@html_rows, '') + '</tbody>' +
                '<tfoot>' +
                '  <tr>' +
                '    <td colspan="6" style="text-align:right"><strong>Total</strong></td>' +
                '    <td style="text-align:right"><strong>' + FORMAT(ISNULL(@total_valor, 0), 'N2') + '</strong></td>' +
                '  </tr>' +
                '</tfoot>' +
                '</table>';
        END
        ELSE
        BEGIN
            SET @html_rows = (
                SELECT
                    '<tr>' +
                    '<td>' + CONVERT(CHAR(10), d.Data, 103) + '</td>' +
                    '<td>' + ISNULL(d.Lancamento, '') + '</td>' +
                    '<td>' + ISNULL(CAST(d.Codigo AS VARCHAR(20)), '') + '</td>' +
                    '<td>' + ISNULL(CAST(d.Contrapartida AS VARCHAR(20)), '') + '</td>' +
                    '<td>' + ISNULL(d.Conta, '') + '</td>' +
                    '<td>' + ISNULL(d.Classificacao, '') + '</td>' +
                    '<td>' + ISNULL(d.ClassifContra, '') + '</td>' +
                    '<td>' + ISNULL(CAST(d.CodHistorico AS VARCHAR(12)), '') + '</td>' +
                    '<td>' + ISNULL(d.Historico, '') + '</td>' +
                    '<td style="text-align:right">' + FORMAT(d.Debito, 'N2') + '</td>' +
                    '<td style="text-align:right">' + FORMAT(d.Credito, 'N2') + '</td>' +
                    '</tr>'
                FROM #Aux_Diario_Contabil AS d
                ORDER BY d.Data, d.Classificacao, d.Lancamento
                FOR XML PATH(''), TYPE
            ).value('.', 'nvarchar(max)');

            SET @html_table =
                '<table>' +
                '<thead>' +
                '  <tr>' +
                '    <th>Data</th>' +
                '    <th>Lançamento</th>' +
                '    <th>Código</th>' +
                '    <th>Contrapartida</th>' +
                '    <th>Conta</th>' +
                '    <th>Classificação</th>' +
                '    <th>Classif. Contra</th>' +
                '    <th>Cód. Histórico</th>' +
                '    <th>Histórico</th>' +
                '    <th>Débito</th>' +
                '    <th>Crédito</th>' +
                '  </tr>' +
                '</thead>' +
                '<tbody>' + ISNULL(@html_rows, '') + '</tbody>' +
                '<tfoot>' +
                '  <tr>' +
                '    <td colspan="9" style="text-align:right"><strong>Totais</strong></td>' +
                '    <td style="text-align:right"><strong>' + FORMAT(ISNULL(@total_debito, 0), 'N2') + '</strong></td>' +
                '    <td style="text-align:right"><strong>' + FORMAT(ISNULL(@total_credito, 0), 'N2') + '</strong></td>' +
                '  </tr>' +
                '</tfoot>' +
                '</table>';
        END

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
            '    tfoot td { background-color: #fafafa; }' +
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
            '  <div style="margin-top:10px;">' + @ds_relatorio + '</div>' +
            '  <div style="text-align:right; font-size:11px; margin-top:10px;">Gerado em: ' + @data_hora_atual + '</div>';

        SET @html_footer = '  </body></html>';
        SET @html        = @html_header + @html_table + @html_footer;

        SELECT ISNULL(@html, '') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        DECLARE @erro NVARCHAR(2048) = CONCAT('pr_egis_relatorio_diario_contabil: ', ERROR_MESSAGE());
        RAISERROR(@erro, 16, 1);
    END CATCH
END
GO
