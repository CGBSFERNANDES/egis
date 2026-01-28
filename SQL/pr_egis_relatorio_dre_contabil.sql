IF OBJECT_ID('dbo.pr_egis_relatorio_dre_contabil', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_dre_contabil;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_dre_contabil
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2025-03-10
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Demonstrativo de Resultado Contábil (cd_relatorio = 411)

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Código totalmente comentado

  Observações:
    - Utiliza a procedure legado pr_demonstracao_resultado para obter os saldos
    - Aceita JSON como array ou objeto com dt_inicial e dt_final
    - Retorna HTML no padrão RelatorioHTML (compatível com pr_egis_processa_fila_relatorio)
    - Para pré-visualização opcional use {"ic_preview":1} no JSON
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_dre_contabil
    @json NVARCHAR(MAX) = NULL -- Parâmetro único vindo do front-end
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    /*---------------------------------------------------------------------------------------------
      1) Variáveis de trabalho
    ---------------------------------------------------------------------------------------------*/
    DECLARE
        @cd_relatorio        INT           = 411,
        @cd_empresa          INT           = NULL,
        @cd_usuario          INT           = NULL,
        @dt_inicial          DATE          = NULL,
        @dt_final            DATE          = NULL,
        @ic_preview          BIT           = 0;

    DECLARE
        @titulo              VARCHAR(200)  = 'DRE - Demonstrativo de Resultado',
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
        @nm_cor_empresa      VARCHAR(20)   = '#1976D2',
        @data_hora_atual     VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          2) Normaliza o JSON (aceita array [ { ... } ])
        -----------------------------------------------------------------------------------------*/
        IF NULLIF(@json, N'') IS NOT NULL AND ISJSON(@json) = 1
        BEGIN
            IF JSON_VALUE(@json, '$[0]') IS NOT NULL
                SET @json = JSON_QUERY(@json, '$[0]');

            SELECT
                @cd_empresa = COALESCE(@cd_empresa, TRY_CAST(JSON_VALUE(@json, '$.cd_empresa') AS INT)),
                @cd_usuario = COALESCE(@cd_usuario, TRY_CAST(JSON_VALUE(@json, '$.cd_usuario') AS INT)),
                @dt_inicial = COALESCE(@dt_inicial, TRY_CAST(JSON_VALUE(@json, '$.dt_inicial') AS DATE)),
                @dt_final   = COALESCE(@dt_final,   TRY_CAST(JSON_VALUE(@json, '$.dt_final')   AS DATE)),
                @ic_preview = COALESCE(@ic_preview, TRY_CAST(JSON_VALUE(@json, '$.ic_preview') AS BIT));
        END

        /*-----------------------------------------------------------------------------------------
          3) Datas padrão: tenta Parametro_Relatorio e cai no mês corrente
        -----------------------------------------------------------------------------------------*/
        IF @dt_inicial IS NULL OR @dt_final IS NULL
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

        /*-----------------------------------------------------------------------------------------
          4) Normaliza parâmetros obrigatórios
        -----------------------------------------------------------------------------------------*/
        SET @cd_empresa = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa());

        /*-----------------------------------------------------------------------------------------
          5) Cabeçalho do relatório (relatorio + empresa)
        -----------------------------------------------------------------------------------------*/
        SELECT
            @titulo              = ISNULL(r.nm_relatorio, @titulo),
            @nm_titulo_relatorio = NULLIF(r.nm_titulo_relatorio, ''),
            @ds_relatorio        = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.relatorio AS r
        WHERE r.cd_relatorio = @cd_relatorio;

        SELECT TOP (1)
            @logo                = ISNULL('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, @logo),
            @nm_cor_empresa      = ISNULL(e.nm_cor_empresa, '#1976D2'),
            @nm_fantasia_empresa = ISNULL(e.nm_fantasia_empresa, ''),
            @nm_endereco_empresa = ISNULL(e.nm_endereco_empresa, ''),
            @cd_numero_endereco  = LTRIM(RTRIM(ISNULL(e.cd_numero, ''))),
            @cd_cep_empresa      = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @nm_cidade           = ISNULL(c.nm_cidade, ''),
            @sg_estado           = ISNULL(est.sg_estado, ''),
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet   = ISNULL(e.nm_email_internet, ''),
            @nm_pais             = ISNULL(p.sg_pais, '')
        FROM Empresa AS e
        LEFT JOIN Cidade AS c  ON c.cd_cidade  = e.cd_cidade
        LEFT JOIN Estado AS est ON est.cd_estado = c.cd_estado
        LEFT JOIN Pais AS p     ON p.cd_pais    = est.cd_pais
        WHERE e.cd_empresa = @cd_empresa;

        /*-----------------------------------------------------------------------------------------
          6) Executa a rotina legada para obter os saldos do DRE
        -----------------------------------------------------------------------------------------*/
        CREATE TABLE #DRE
        (
            Conta               INT,
            Grupo               INT,
            Descricao_Grupo     VARCHAR(200),
            Classificacao       VARCHAR(50),
            Descricao_Conta     VARCHAR(200),
            ic_conta_balanco    CHAR(1),
            Quantidade_Grau_Conta INT,
            Saldo_Conta         DECIMAL(18, 2),
            Tipo_Saldo          CHAR(1)
        );

        INSERT INTO #DRE
        EXEC pr_demonstracao_resultado
            @dt_inicial = @dt_inicial,
            @dt_final   = @dt_final;

        /*-----------------------------------------------------------------------------------------
          7) Projeção final (colunas de saída + totais por grupo)
        -----------------------------------------------------------------------------------------*/
        ;WITH base AS (
            SELECT
                Grupo,
                Descricao_Grupo,
                Classificacao,
                Conta,
                Descricao_Conta,
                Tipo_Saldo,
                ISNULL(Saldo_Conta, 0) AS Saldo_Conta,
                CASE WHEN ISNULL(Tipo_Saldo, 'C') = 'D'
                        THEN -ISNULL(Saldo_Conta, 0)
                     ELSE  ISNULL(Saldo_Conta, 0)
                END AS Valor_Ajustado
            FROM #DRE
        ),
        totais AS (
            SELECT
                Grupo,
                Descricao_Grupo,
                SUM(Valor_Ajustado) AS Resultado_Grupo
            FROM base
            GROUP BY Grupo, Descricao_Grupo
        )
        SELECT
            b.Grupo,
            b.Descricao_Grupo,
            b.Classificacao,
            b.Conta,
            b.Descricao_Conta,
            b.Tipo_Saldo,
            b.Saldo_Conta,
            b.Valor_Ajustado AS Resultado,
            CAST(0 AS BIT) AS ic_total_grupo
        INTO #ResultadoDRE
        FROM base AS b;

        INSERT INTO #ResultadoDRE
        (
            Grupo,
            Descricao_Grupo,
            Classificacao,
            Conta,
            Descricao_Conta,
            Tipo_Saldo,
            Saldo_Conta,
            Resultado,
            ic_total_grupo
        )
        SELECT
            t.Grupo,
            t.Descricao_Grupo,
            NULL,
            NULL,
            'Total do Grupo',
            NULL,
            NULL,
            t.Resultado_Grupo,
            CAST(1 AS BIT)
        FROM totais AS t;

        DECLARE @resultado_periodo DECIMAL(18, 2) = 0;

        SELECT @resultado_periodo = SUM(Resultado)
        FROM #ResultadoDRE
        WHERE ic_total_grupo = 1;

        /* Preview de dados para conferência quando solicitado */
        IF ISNULL(@ic_preview, 0) = 1
        BEGIN
            SELECT *
            FROM #ResultadoDRE
            ORDER BY Grupo, ic_total_grupo, Classificacao, Conta;
            RETURN;
        END

        /*-----------------------------------------------------------------------------------------
          8) Monta HTML (RelatorioHTML)
        -----------------------------------------------------------------------------------------*/
        DECLARE
            @html_rows   NVARCHAR(MAX),
            @html_table  NVARCHAR(MAX),
            @html_header NVARCHAR(MAX),
            @html_footer NVARCHAR(MAX),
            @html        NVARCHAR(MAX),
            @titulo_exibir VARCHAR(200);

        SET @titulo_exibir = ISNULL(NULLIF(@nm_titulo_relatorio, ''), @titulo);

        SET @html_rows = (
            SELECT
                '<tr' +
                CASE WHEN r.ic_total_grupo = 1 THEN ' style="font-weight:bold;background-color:#f6f6f6;"' ELSE '' END +
                '>' +
                '<td>' + ISNULL(CAST(r.Grupo AS VARCHAR(10)), '') + '</td>' +
                '<td>' + ISNULL(r.Descricao_Grupo, '') + '</td>' +
                '<td>' + ISNULL(r.Classificacao, '') + '</td>' +
                '<td>' + ISNULL(CAST(r.Conta AS VARCHAR(20)), '') + '</td>' +
                '<td>' + ISNULL(r.Descricao_Conta, '') + '</td>' +
                '<td>' + ISNULL(r.Tipo_Saldo, '') + '</td>' +
                '<td style="text-align:right">' + FORMAT(ISNULL(r.Saldo_Conta, 0), 'N2') + '</td>' +
                '<td style="text-align:right">' + FORMAT(ISNULL(r.Resultado, 0), 'N2') + '</td>' +
                '</tr>'
            FROM #ResultadoDRE AS r
            ORDER BY r.Grupo, r.ic_total_grupo, r.Classificacao, r.Conta
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)');

        SET @html_table =
            '<table>' +
            '<thead>' +
            '  <tr>' +
            '    <th>Grupo</th>' +
            '    <th>Descrição do Grupo</th>' +
            '    <th>Classificação</th>' +
            '    <th>Conta</th>' +
            '    <th>Descrição da Conta</th>' +
            '    <th>Tipo</th>' +
            '    <th>Saldo</th>' +
            '    <th>Resultado</th>' +
            '  </tr>' +
            '</thead>' +
            '<tbody>' + ISNULL(@html_rows, '') + '</tbody>' +
            '<tfoot>' +
            '  <tr>' +
            '    <td colspan="7" style="text-align:right"><strong>Resultado do Período</strong></td>' +
            '    <td style="text-align:right"><strong>' + FORMAT(ISNULL(@resultado_periodo, 0), 'N2') + '</strong></td>' +
            '  </tr>' +
            '</tfoot>' +
            '</table>';

        SET @html_header =
            '<html>' +
            '<head>' +
            '  <meta charset="UTF-8">' +
            '  <title>' + ISNULL(@titulo_exibir, 'Relatório') + '</title>' +
            '  <style>' +
            '    body { font-family: Arial, sans-serif; color: #333; padding: 20px; }' +
            '    h1 { color: ' + @nm_cor_empresa + '; margin-bottom: 4px; }' +
            '    h3 { color: #555; margin-top: 0; }' +
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
            '      <h3>Demonstrativo de Resultado</h3>' +
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
        DECLARE @errMsg NVARCHAR(2048) = FORMATMESSAGE(
            'pr_egis_relatorio_dre_contabil falhou: %s (linha %d)',
            ERROR_MESSAGE(),
            ERROR_LINE()
        );

        THROW ERROR_NUMBER(), @errMsg, ERROR_STATE();
    END CATCH
END
GO
