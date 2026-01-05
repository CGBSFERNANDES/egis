IF OBJECT_ID('dbo.pr_egis_relatorio_balancete_verificacao', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_balancete_verificacao;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_balancete_verificacao
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2025-02-14
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Balancete de Verificação (cd_relatorio = 410)

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Código comentado

  Observações:
    - Utiliza a procedure legado pr_balancete_verificacao para montar os saldos
    - Aceita JSON como array ou objeto com as datas (dt_inicial, dt_final)
    - Retorna HTML no padrão RelatorioHTML (compatível com pr_egis_processa_fila_relatorio)
    - Para pré-visualização opcional use {"ic_preview":1} no JSON
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_balancete_verificacao
    @json NVARCHAR(MAX) = NULL -- Parâmetros vindos do front-end (datas e flags opcionais)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    /*---------------------------------------------------------------------------------------------
      1) Variáveis de trabalho
    ---------------------------------------------------------------------------------------------*/
    DECLARE
        @cd_relatorio                 INT           = 410,
        @cd_empresa                   INT           = NULL,
        @cd_usuario                   INT           = NULL,
        @dt_inicial                   DATE          = NULL,
        @dt_final                     DATE          = NULL,
        @cd_exercicio                 INT           = NULL,
        @ic_parametro                 INT           = 2,      -- 1=Completo, 2=Analítico, 3/4=Filtros
        @ic_imprime_sem_movimento     CHAR(1)       = 'N',    -- 'S' imprime zeradas
        @cd_mascara_conta_pesq        VARCHAR(100)  = '',
        @ic_preview                   BIT           = 0;      -- 1 = retorna dataset ao invés de HTML

    DECLARE
        @titulo              VARCHAR(200)  = 'Balancete de Verificação',
        @logo                VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
        @nm_cor_empresa      VARCHAR(20)   = '#1976D2',
        @nm_endereco_empresa VARCHAR(200)  = '',
        @cd_telefone_empresa VARCHAR(200)  = '',
        @nm_email_internet   VARCHAR(200)  = '',
        @nm_cidade           VARCHAR(200)  = '',
        @sg_estado           VARCHAR(10)   = '',
        @nm_fantasia_empresa VARCHAR(200)  = '',
        @cd_numero_endereco  VARCHAR(20)   = '',
        @cd_cep_empresa      VARCHAR(20)   = '',
        @nm_pais             VARCHAR(20)   = '',
        @nm_titulo_relatorio VARCHAR(200)  = NULL,
        @ds_relatorio        VARCHAR(8000) = '',
        @data_hora_atual     VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          2) Normaliza JSON (aceita array [ { ... } ])
        -----------------------------------------------------------------------------------------*/
        IF NULLIF(@json, N'') IS NOT NULL AND ISJSON(@json) = 1
        BEGIN
            IF JSON_VALUE(@json, '$[0]') IS NOT NULL
                SET @json = JSON_QUERY(@json, '$[0]');

            SELECT
                @cd_empresa               = COALESCE(@cd_empresa, TRY_CAST(JSON_VALUE(@json, '$.cd_empresa') AS INT)),
                @cd_usuario               = COALESCE(@cd_usuario, TRY_CAST(JSON_VALUE(@json, '$.cd_usuario') AS INT)),
                @dt_inicial               = COALESCE(@dt_inicial, TRY_CAST(JSON_VALUE(@json, '$.dt_inicial') AS DATE)),
                @dt_final                 = COALESCE(@dt_final,   TRY_CAST(JSON_VALUE(@json, '$.dt_final')   AS DATE)),
                @ic_parametro             = COALESCE(@ic_parametro, TRY_CAST(JSON_VALUE(@json, '$.ic_parametro') AS INT)),
                @ic_imprime_sem_movimento = COALESCE(@ic_imprime_sem_movimento, TRY_CAST(JSON_VALUE(@json, '$.ic_imprime_sem_movimento') AS CHAR(1))),
                @cd_mascara_conta_pesq    = COALESCE(@cd_mascara_conta_pesq, JSON_VALUE(@json, '$.cd_mascara_conta')),
                @ic_preview               = COALESCE(@ic_preview, TRY_CAST(JSON_VALUE(@json, '$.ic_preview') AS BIT));
        END

        /*-----------------------------------------------------------------------------------------
          3) Datas padrão: tenta Parametro_Relatorio e cai no mês corrente
        -----------------------------------------------------------------------------------------*/
        SELECT
            @dt_inicial = COALESCE(@dt_inicial, pr.dt_inicial),
            @dt_final   = COALESCE(@dt_final,   pr.dt_final)
        FROM Parametro_Relatorio AS pr WITH (NOLOCK)
        WHERE pr.cd_relatorio = @cd_relatorio
          AND (@cd_usuario IS NULL OR pr.cd_usuario_relatorio = @cd_usuario);

        IF @dt_inicial IS NULL OR @dt_final IS NULL
        BEGIN
            SET @dt_inicial = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
            SET @dt_final   = EOMONTH(@dt_inicial);
        END

        /*-----------------------------------------------------------------------------------------
          4) Normaliza parâmetros obrigatórios
        -----------------------------------------------------------------------------------------*/
        SET @cd_empresa = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa());
        IF @ic_parametro NOT IN (1, 2, 3, 4, 9) SET @ic_parametro = 2;
        IF @ic_imprime_sem_movimento NOT IN ('S', 'N') SET @ic_imprime_sem_movimento = 'N';
        SET @cd_mascara_conta_pesq = ISNULL(@cd_mascara_conta_pesq, '');

        /*-----------------------------------------------------------------------------------------
          5) Descobre exercício contábil pelo período informado
        -----------------------------------------------------------------------------------------*/
        SELECT TOP (1)
            @cd_exercicio = pc.cd_exercicio
        FROM Parametro_contabil AS pc WITH (NOLOCK)
        WHERE pc.cd_empresa = @cd_empresa
          AND @dt_inicial >= pc.dt_inicial_exercicio
          AND @dt_final   <= pc.dt_final_exercicio
        ORDER BY pc.dt_inicial_exercicio DESC;

        IF @cd_exercicio IS NULL
        BEGIN
            SELECT TOP (1)
                @cd_exercicio = pc.cd_exercicio
            FROM Parametro_contabil AS pc WITH (NOLOCK)
            WHERE pc.cd_empresa = @cd_empresa
              AND ISNULL(pc.ic_exercicio_ativo, 'N') = 'S'
            ORDER BY pc.dt_inicial_exercicio DESC;
        END

        IF @cd_exercicio IS NULL
            SET @cd_exercicio = 1; -- fallback seguro para não quebrar a chamada legado

        /*-----------------------------------------------------------------------------------------
          6) Cabeçalho do relatório (relatorio + empresa)
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
          7) Tabela temporária para capturar a saída do legado
        -----------------------------------------------------------------------------------------*/
        CREATE TABLE #Balancete (
            cd_conta               INT,
            cd_conta_reduzido      INT,
            cd_conta_sintetica     INT,
            cd_grupo_conta         INT,
            qt_grau_conta          INT,
            cd_mascara_conta       VARCHAR(50),
            nm_conta               VARCHAR(200),
            vl_saldo_inicial       DECIMAL(15, 2),
            ic_saldo_inicial       CHAR(1),
            vl_debito_conta        DECIMAL(15, 2),
            vl_credito_conta       DECIMAL(15, 2),
            vl_saldo_atual         DECIMAL(15, 2),
            ic_saldo_atual         CHAR(1),
            qt_lancamento          INT,
            ic_conta_analitica     CHAR(1),
            ic_tipo_conta          CHAR(1),
            ic_tipo_grupo_conta    CHAR(1)
        );

        INSERT INTO #Balancete
        EXEC pr_balancete_verificacao
            @ic_parametro             = @ic_parametro,
            @ic_imprime_sem_movimento = @ic_imprime_sem_movimento,
            @cd_empresa               = @cd_empresa,
            @cd_exercicio             = @cd_exercicio,
            @dt_inicial               = @dt_inicial,
            @dt_final                 = @dt_final,
            @cd_mascara_conta_pesq    = @cd_mascara_conta_pesq,
            @cd_usuario               = ISNULL(@cd_usuario, 0),
            @cd_controle              = 0;

        /*-----------------------------------------------------------------------------------------
          8) Projeção final (colunas de saída)
        -----------------------------------------------------------------------------------------*/
        ;WITH dados AS (
            SELECT
                cd_mascara_conta AS Classificacao,
                nm_conta         AS Conta,
                CASE WHEN ic_saldo_inicial = 'D' THEN vl_saldo_inicial ELSE 0 END AS SaldoInicialDebito,
                CASE WHEN ic_saldo_inicial = 'C' THEN vl_saldo_inicial ELSE 0 END AS SaldoInicialCredito,
                vl_debito_conta   AS MovimentoDebito,
                vl_credito_conta  AS MovimentoCredito,
                CASE WHEN ic_saldo_atual = 'D' THEN vl_saldo_atual ELSE 0 END AS SaldoFinalDebito,
                CASE WHEN ic_saldo_atual = 'C' THEN vl_saldo_atual ELSE 0 END AS SaldoFinalCredito
            FROM #Balancete
        )
        SELECT *
        INTO #ResultadoBalancete
        FROM dados;

        /* Preview de dados para conferência quando solicitado */
        IF ISNULL(@ic_preview, 0) = 1
        BEGIN
            SELECT *
            FROM #ResultadoBalancete
            ORDER BY Classificacao, Conta;
            RETURN;
        END

        /*-----------------------------------------------------------------------------------------
          9) Totais para o rodapé
        -----------------------------------------------------------------------------------------*/
        DECLARE
            @tot_si_deb DECIMAL(18, 2) = 0,
            @tot_si_cred DECIMAL(18, 2) = 0,
            @tot_mov_deb DECIMAL(18, 2) = 0,
            @tot_mov_cred DECIMAL(18, 2) = 0,
            @tot_sf_deb DECIMAL(18, 2) = 0,
            @tot_sf_cred DECIMAL(18, 2) = 0,
            @titulo_exibir VARCHAR(200);

        SELECT
            @tot_si_deb  = SUM(SaldoInicialDebito),
            @tot_si_cred = SUM(SaldoInicialCredito),
            @tot_mov_deb = SUM(MovimentoDebito),
            @tot_mov_cred= SUM(MovimentoCredito),
            @tot_sf_deb  = SUM(SaldoFinalDebito),
            @tot_sf_cred = SUM(SaldoFinalCredito)
        FROM #ResultadoBalancete;

        SET @titulo_exibir = ISNULL(NULLIF(@nm_titulo_relatorio, ''), @titulo);

        /*-----------------------------------------------------------------------------------------
          10) Monta HTML (RelatorioHTML)
        -----------------------------------------------------------------------------------------*/
        DECLARE
            @html_header NVARCHAR(MAX),
            @html_rows   NVARCHAR(MAX),
            @html_table  NVARCHAR(MAX),
            @html_footer NVARCHAR(MAX),
            @html        NVARCHAR(MAX);

        SET @html_rows = (
            SELECT
                '<tr>' +
                '<td>' + ISNULL(r.Classificacao, '') + '</td>' +
                '<td>' + ISNULL(r.Conta, '') + '</td>' +
                '<td style="text-align:right">' + FORMAT(ISNULL(r.SaldoInicialDebito, 0), 'N2') + '</td>' +
                '<td style="text-align:right">' + FORMAT(ISNULL(r.SaldoInicialCredito, 0), 'N2') + '</td>' +
                '<td style="text-align:right">' + FORMAT(ISNULL(r.MovimentoDebito, 0), 'N2') + '</td>' +
                '<td style="text-align:right">' + FORMAT(ISNULL(r.MovimentoCredito, 0), 'N2') + '</td>' +
                '<td style="text-align:right">' + FORMAT(ISNULL(r.SaldoFinalDebito, 0), 'N2') + '</td>' +
                '<td style="text-align:right">' + FORMAT(ISNULL(r.SaldoFinalCredito, 0), 'N2') + '</td>' +
                '</tr>'
            FROM #ResultadoBalancete AS r
            ORDER BY r.Classificacao, r.Conta
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)');

        SET @html_table =
            '<table>' +
            '<thead>' +
            '  <tr>' +
            '    <th>Classificação</th>' +
            '    <th>Conta</th>' +
            '    <th>Saldo Inicial (D)</th>' +
            '    <th>Saldo Inicial (C)</th>' +
            '    <th>Mov. Débito</th>' +
            '    <th>Mov. Crédito</th>' +
            '    <th>Saldo Final (D)</th>' +
            '    <th>Saldo Final (C)</th>' +
            '  </tr>' +
            '</thead>' +
            '<tbody>' + ISNULL(@html_rows, '') + '</tbody>' +
            '<tfoot>' +
            '  <tr>' +
            '    <td colspan="2" style="text-align:right"><strong>Totais</strong></td>' +
            '    <td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_si_deb, 0), 'N2') + '</strong></td>' +
            '    <td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_si_cred, 0), 'N2') + '</strong></td>' +
            '    <td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_mov_deb, 0), 'N2') + '</strong></td>' +
            '    <td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_mov_cred, 0), 'N2') + '</strong></td>' +
            '    <td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_sf_deb, 0), 'N2') + '</strong></td>' +
            '    <td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_sf_cred, 0), 'N2') + '</strong></td>' +
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
            '      <h3>Balancete de Verificação</h3>' +
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
            'pr_egis_relatorio_balancete_verificacao falhou: %s (linha %d)',
            ERROR_MESSAGE(),
            ERROR_LINE()
        );

        THROW ERROR_NUMBER(), @errMsg, ERROR_STATE();
    END CATCH
END
GO
