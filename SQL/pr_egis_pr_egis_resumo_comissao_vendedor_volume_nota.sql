IF OBJECT_ID('dbo.pr_egis_pr_egis_resumo_comissao_vendedor_volume_nota', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_pr_egis_resumo_comissao_vendedor_volume_nota;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_pr_egis_resumo_comissao_vendedor_volume_nota
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2025-02-18
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Resumo de Comissão por Vendedor (cd_relatorio = 427)

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Código comentado

  Observações:
    - Utiliza a procedure legado pr_egis_resumo_comissao_vendedor
    - Aceita JSON como array ou objeto com (dt_inicial, dt_final)
    - Retorna HTML no padrão RelatorioHTML
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_pr_egis_resumo_comissao_vendedor_volume_nota
    @json NVARCHAR(MAX) = NULL -- Parâmetros vindos do front-end (datas)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    /*---------------------------------------------------------------------------------------------
      1) Variáveis de trabalho
    ---------------------------------------------------------------------------------------------*/
    DECLARE
        @cd_relatorio     INT          = 427,
        @cd_empresa       INT          = NULL,
        @cd_usuario       INT          = NULL,
        @dt_inicial       DATE         = NULL,
        @dt_final         DATE         = NULL,
        @qt_registros     INT          = 0,
        @vl_total_base    DECIMAL(25,2) = 0,
        @vl_total_comissao DECIMAL(25,2) = 0;

    DECLARE
        @titulo              VARCHAR(200)  = 'Resumo de Comissão por Vendedor',
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

    /*---------------------------------------------------------------------------------------------
      2) HTML (partes)
    ---------------------------------------------------------------------------------------------*/
    DECLARE
        @html_header   NVARCHAR(MAX) = N'',
        @html_cabecalho NVARCHAR(MAX) = N'',
        @html_detalhe  NVARCHAR(MAX) = N'',
        @html_totais   NVARCHAR(MAX) = N'',
        @html_footer   NVARCHAR(MAX) = N'',
        @html          NVARCHAR(MAX) = N'';

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          3) Normaliza JSON (aceita array [ { ... } ])
        -----------------------------------------------------------------------------------------*/
        IF NULLIF(@json, N'') IS NOT NULL AND ISJSON(@json) = 1
        BEGIN
            IF JSON_VALUE(@json, '$[0]') IS NOT NULL
                SET @json = JSON_QUERY(@json, '$[0]');

            SELECT
                @dt_inicial = COALESCE(@dt_inicial, TRY_CAST(JSON_VALUE(@json, '$.dt_inicial') AS DATE)),
                @dt_final   = COALESCE(@dt_final,   TRY_CAST(JSON_VALUE(@json, '$.dt_final')   AS DATE)),
                @cd_usuario = COALESCE(@cd_usuario, TRY_CAST(JSON_VALUE(@json, '$.cd_usuario') AS INT)),
                @cd_empresa = COALESCE(@cd_empresa, TRY_CAST(JSON_VALUE(@json, '$.cd_empresa') AS INT));
        END

        /*-----------------------------------------------------------------------------------------
          4) Datas padrão: tenta Parametro_Relatorio e cai no mês corrente
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
          5) Normaliza parâmetros obrigatórios
        -----------------------------------------------------------------------------------------*/
        SET @cd_empresa = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa());

        /*-----------------------------------------------------------------------------------------
          6) Dados da empresa (EgisAdmin)
        -----------------------------------------------------------------------------------------*/
        SELECT
            @logo                = ISNULL('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, @logo),
            @nm_cor_empresa      = ISNULL(e.nm_cor_empresa, @nm_cor_empresa),
            @nm_endereco_empresa = ISNULL(e.nm_endereco_empresa, ''),
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet   = ISNULL(e.nm_email_internet, ''),
            @nm_cidade           = ISNULL(c.nm_cidade, ''),
            @sg_estado           = ISNULL(es.sg_estado, ''),
            @nm_fantasia_empresa = ISNULL(e.nm_fantasia_empresa, ''),
            @cd_cep_empresa      = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @cd_numero_endereco  = LTRIM(RTRIM(ISNULL(e.cd_numero, 0))),
            @nm_pais             = LTRIM(RTRIM(ISNULL(p.sg_pais, '')))
        FROM egisadmin.dbo.empresa AS e WITH (NOLOCK)
        LEFT JOIN Estado AS es WITH (NOLOCK) ON es.cd_estado = e.cd_estado
        LEFT JOIN Cidade AS c WITH (NOLOCK) ON c.cd_cidade = e.cd_cidade AND c.cd_estado = e.cd_estado
        LEFT JOIN Pais AS p WITH (NOLOCK) ON p.cd_pais = e.cd_pais
        WHERE e.cd_empresa = @cd_empresa;

        SELECT
            @nm_titulo_relatorio = NULLIF(r.nm_titulo_relatorio, ''),
            @ds_relatorio        = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.Relatorio AS r WITH (NOLOCK)
        WHERE r.cd_relatorio = @cd_relatorio;

        /*-----------------------------------------------------------------------------------------
          7) Coleta dados base (procedure legado)
        -----------------------------------------------------------------------------------------*/
        CREATE TABLE #resumo_comissao_vendedor (
            cd_vendedor                INT,
            nm_fantasia_vendedor       VARCHAR(200),
            nm_vendedor                VARCHAR(200),
            nm_tipo_vendedor           VARCHAR(200),
            nm_tipo_pessoa             VARCHAR(200),
            cd_cnpj_vendedor           VARCHAR(50),
            cd_celular                 VARCHAR(50),
            nm_email_vendedor          VARCHAR(200),
            pc_comissao_vendedor       DECIMAL(18,2),
            nm_pix_vendedor            VARCHAR(200),
            cd_numero_banco            VARCHAR(50),
            cd_agencia_banco_vendedor  VARCHAR(50),
            cd_conta_corrente          VARCHAR(50),
            vl_base_calculo            DECIMAL(25,2),
            vl_comissao                DECIMAL(25,2)
        );

        INSERT INTO #resumo_comissao_vendedor
        EXEC dbo.pr_egis_resumo_comissao_vendedor
            @cd_parametro = 0,
            @cd_usuario   = ISNULL(@cd_usuario, 0);

        /*-----------------------------------------------------------------------------------------
          8) Totais (count / soma da base de cálculo e comissão)
        -----------------------------------------------------------------------------------------*/
        SELECT
            @qt_registros      = COUNT(1),
            @vl_total_base     = SUM(ISNULL(vl_base_calculo, 0)),
            @vl_total_comissao = SUM(ISNULL(vl_comissao, 0))
        FROM #resumo_comissao_vendedor;

        /*-----------------------------------------------------------------------------------------
          9) Monta HTML (RelatorioHTML)
        -----------------------------------------------------------------------------------------*/
        SET @html_header =
            '<html><head><meta charset="utf-8">' +
            '<style>' +
            'body{font-family:Arial, sans-serif;font-size:12px;color:#333;margin:0;padding:20px;}' +
            'table{width:100%;border-collapse:collapse;margin-top:10px;}' +
            'th,td{border:1px solid #ccc;padding:6px 8px;text-align:left;font-size:11px;}' +
            'th{background:' + @nm_cor_empresa + ';color:#fff;}' +
            '.section-title{font-size:16px;font-weight:bold;margin-top:10px;}' +
            '.totals{margin-top:10px;font-weight:bold;}' +
            '.report-date-time{text-align:right;font-size:11px;margin-top:10px;}' +
            '</style></head><body>';

        SET @html_cabecalho =
            '  <div style="display:flex;justify-content:space-between;align-items:center;">' +
            '    <div style="width:30%;padding-right:20px;"><img src="' + @logo + '" alt="Logo" style="max-width:220px;"></div>' +
            '    <div style="width:70%;padding-left:10px;">' +
            '      <div class="section-title">' + ISNULL(@nm_titulo_relatorio, @titulo) + '</div>' +
            '      <p><strong>' + ISNULL(@nm_fantasia_empresa, '') + '</strong></p>' +
            '      <p>' + @nm_endereco_empresa + ', ' + @cd_numero_endereco + ' - ' + @cd_cep_empresa + ' - ' + @nm_cidade + ' - ' + @sg_estado + ' - ' + @nm_pais + '</p>' +
            '      <p><strong>Fone: </strong>' + @cd_telefone_empresa + ' | <strong>Email: </strong>' + @nm_email_internet + '</p>' +
            '      <p><strong>Período: </strong>' + CONVERT(CHAR(10), @dt_inicial, 103) + ' a ' + CONVERT(CHAR(10), @dt_final, 103) + '</p>' +
            '    </div>' +
            '  </div>' +
            '  <div style="margin-top:10px;">' + ISNULL(@ds_relatorio, '') + '</div>';

        SET @html_detalhe =
            '<table>' +
            '<thead>' +
            '<tr>' +
            '<th>cd_vendedor</th>' +
            '<th>nm_fantasia_vendedor</th>' +
            '<th>nm_vendedor</th>' +
            '<th>nm_tipo_vendedor</th>' +
            '<th>nm_tipo_pessoa</th>' +
            '<th>cd_cnpj_vendedor</th>' +
            '<th>cd_celular</th>' +
            '<th>nm_email_vendedor</th>' +
            '<th>pc_comissao_vendedor</th>' +
            '<th>nm_pix_vendedor</th>' +
            '<th>cd_numero_banco</th>' +
            '<th>cd_agencia_banco_vendedor</th>' +
            '<th>cd_conta_corrente</th>' +
            '<th>vl_base_calculo</th>' +
            '<th>vl_comissao</th>' +
            '</tr>' +
            '</thead><tbody>' +
            ISNULL((
                SELECT
                    '<tr>' +
                    '<td>' + CAST(r.cd_vendedor AS VARCHAR(20)) + '</td>' +
                    '<td>' + ISNULL(r.nm_fantasia_vendedor, '') + '</td>' +
                    '<td>' + ISNULL(r.nm_vendedor, '') + '</td>' +
                    '<td>' + ISNULL(r.nm_tipo_vendedor, '') + '</td>' +
                    '<td>' + ISNULL(r.nm_tipo_pessoa, '') + '</td>' +
                    '<td>' + ISNULL(r.cd_cnpj_vendedor, '') + '</td>' +
                    '<td>' + ISNULL(r.cd_celular, '') + '</td>' +
                    '<td>' + ISNULL(r.nm_email_vendedor, '') + '</td>' +
                    '<td style="text-align:right;">' + CONVERT(VARCHAR(30), CAST(ISNULL(r.pc_comissao_vendedor, 0) AS MONEY), 1) + '</td>' +
                    '<td>' + ISNULL(r.nm_pix_vendedor, '') + '</td>' +
                    '<td>' + ISNULL(r.cd_numero_banco, '') + '</td>' +
                    '<td>' + ISNULL(r.cd_agencia_banco_vendedor, '') + '</td>' +
                    '<td>' + ISNULL(r.cd_conta_corrente, '') + '</td>' +
                    '<td style="text-align:right;">' + CONVERT(VARCHAR(30), CAST(ISNULL(r.vl_base_calculo, 0) AS MONEY), 1) + '</td>' +
                    '<td style="text-align:right;">' + CONVERT(VARCHAR(30), CAST(ISNULL(r.vl_comissao, 0) AS MONEY), 1) + '</td>' +
                    '</tr>'
                FROM #resumo_comissao_vendedor AS r
                ORDER BY r.nm_vendedor
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), '') +
            '</tbody></table>';

        SET @html_totais =
            '<div class="totals">' +
            'Total de Registros: ' + CAST(@qt_registros AS VARCHAR(20)) +
            ' | Soma Base de Cálculo: ' + CONVERT(VARCHAR(30), CAST(@vl_total_base AS MONEY), 1) +
            ' | Soma Comissão: ' + CONVERT(VARCHAR(30), CAST(@vl_total_comissao AS MONEY), 1) +
            '</div>';

        SET @html_footer =
            '<div class="report-date-time">Gerado em: ' + @data_hora_atual + '</div>' +
            '</body></html>';

        SET @html = @html_header + @html_cabecalho + @html_detalhe + @html_totais + @html_footer;

        SELECT ISNULL(@html, '') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        DECLARE @errMsg NVARCHAR(2048) = FORMATMESSAGE(
            'pr_egis_pr_egis_resumo_comissao_vendedor_volume_nota falhou: %s (linha %d)',
            ERROR_MESSAGE(),
            ERROR_LINE()
        );

        THROW ERROR_NUMBER(), @errMsg, ERROR_STATE();
    END CATCH
END
GO
