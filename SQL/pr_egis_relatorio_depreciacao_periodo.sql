IF EXISTS (SELECT name
           FROM sysobjects
           WHERE name = N'pr_egis_relatorio_depreciacao_periodo'
             AND type = 'P')
    DROP PROCEDURE pr_egis_relatorio_depreciacao_periodo
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_depreciacao_periodo
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2025-04-07
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatorio HTML - Depreciacao do Periodo de Apuracao (cd_relatorio = 444)

  Requisitos:
    - Somente 1 parametro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Codigo comentado
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE pr_egis_relatorio_depreciacao_periodo
    @json NVARCHAR(MAX) = ''
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        ------------------------------------------------------------------------------
        -- Variaveis de controle
        ------------------------------------------------------------------------------
        DECLARE
            @cd_relatorio            INT           = 444,
            @cd_empresa              INT           = 0,
            @cd_usuario              INT           = 0,
            @dt_inicial              DATETIME      = NULL,
            @dt_final                DATETIME      = NULL,
            @dt_hoje                 DATETIME      = NULL,
            @titulo                  VARCHAR(200)  = 'Relatorio de Depreciacao do Periodo de Apuracao',
            @logo                    VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
            @nm_cor_empresa          VARCHAR(20)   = '#1976D2',
            @nm_endereco_empresa     VARCHAR(200)  = '',
            @cd_telefone_empresa     VARCHAR(200)  = '',
            @nm_email_internet       VARCHAR(200)  = '',
            @nm_cidade               VARCHAR(200)  = '',
            @sg_estado               VARCHAR(10)   = '',
            @nm_fantasia_empresa     VARCHAR(200)  = '',
            @cd_numero_endereco_emp  VARCHAR(20)   = '',
            @cd_cep_empresa          VARCHAR(20)   = '',
            @nm_pais                 VARCHAR(20)   = '',
            @cd_cnpj_empresa         VARCHAR(60)   = '',
            @cd_inscestadual_empresa VARCHAR(100)  = '',
            @nm_dominio_internet     VARCHAR(200)  = '',
            @ds_relatorio            VARCHAR(8000) = '',
            @data_hora_atual         VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

        ------------------------------------------------------------------------------
        -- Extracao de parametros do JSON (obrigatorio)
        ------------------------------------------------------------------------------
        SET @json = ISNULL(@json, '');

        IF @json <> ''
        BEGIN
            SELECT
                1                                                    AS id_registro,
                IDENTITY(INT, 1, 1)                                  AS id,
                valores.[key] COLLATE SQL_Latin1_General_CP1_CI_AI   AS campo,
                valores.[value]                                      AS valor
            INTO #json
            FROM openjson(@json) AS root
            CROSS APPLY openjson(root.value) AS valores;

            SELECT @cd_empresa   = valor FROM #json WHERE campo = 'cd_empresa';
            SELECT @cd_usuario   = valor FROM #json WHERE campo = 'cd_usuario';
            SELECT @dt_inicial   = valor FROM #json WHERE campo = 'dt_inicial';
            SELECT @dt_final     = valor FROM #json WHERE campo = 'dt_final';
            SELECT @cd_relatorio = valor FROM #json WHERE campo = 'cd_relatorio';
        END

        SET @cd_relatorio = ISNULL(@cd_relatorio, 444);
        SET @cd_empresa = CASE WHEN ISNULL(@cd_empresa, 0) = 0 THEN dbo.fn_empresa() ELSE @cd_empresa END;

        ------------------------------------------------------------------------------
        -- Parametros do relatorio (quando disponiveis)
        ------------------------------------------------------------------------------
        SELECT
            @titulo       = ISNULL(r.nm_relatorio, @titulo),
            @ds_relatorio = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.Relatorio AS r
        WHERE r.cd_relatorio = @cd_relatorio;

        SELECT
            @dt_inicial = ISNULL(pr.dt_inicial, @dt_inicial),
            @dt_final   = ISNULL(pr.dt_final, @dt_final)
        FROM Parametro_Relatorio AS pr
        WHERE pr.cd_relatorio = @cd_relatorio
          AND pr.cd_usuario   = @cd_usuario;

        SET @dt_hoje = CONVERT(DATETIME, LEFT(CONVERT(VARCHAR, GETDATE(), 121), 10) + ' 00:00:00', 121);

        IF @dt_inicial IS NULL OR @dt_inicial = '19000101'
        BEGIN
            SET @dt_inicial = dbo.fn_data_inicial(MONTH(@dt_hoje), YEAR(@dt_hoje));
            SET @dt_final   = dbo.fn_data_final(MONTH(@dt_hoje), YEAR(@dt_hoje));
        END

        ------------------------------------------------------------------------------
        -- Dados da empresa
        ------------------------------------------------------------------------------
        SELECT
            @logo                    = ISNULL('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, @logo),
            @nm_cor_empresa          = CASE WHEN ISNULL(e.nm_cor_empresa, '') <> '' THEN e.nm_cor_empresa ELSE '#1976D2' END,
            @nm_endereco_empresa     = ISNULL(e.nm_endereco_empresa, ''),
            @cd_telefone_empresa     = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet       = ISNULL(e.nm_email_internet, ''),
            @nm_cidade               = ISNULL(c.nm_cidade, ''),
            @sg_estado               = ISNULL(es.sg_estado, ''),
            @nm_fantasia_empresa     = ISNULL(e.nm_fantasia_empresa, ''),
            @cd_cep_empresa          = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @cd_numero_endereco_emp  = LTRIM(RTRIM(ISNULL(e.cd_numero, ''))),
            @nm_pais                 = LTRIM(RTRIM(ISNULL(p.sg_pais, ''))),
            @cd_cnpj_empresa         = dbo.fn_formata_cnpj(LTRIM(RTRIM(ISNULL(e.cd_cgc_empresa, '')))),
            @cd_inscestadual_empresa = LTRIM(RTRIM(ISNULL(e.cd_iest_empresa, ''))),
            @nm_dominio_internet     = LTRIM(RTRIM(ISNULL(e.nm_dominio_internet, '')))
        FROM egisadmin.dbo.empresa AS e WITH (NOLOCK)
        LEFT JOIN Estado AS es WITH (NOLOCK) ON es.cd_estado = e.cd_estado
        LEFT JOIN Cidade AS c WITH (NOLOCK) ON c.cd_cidade = e.cd_cidade AND c.cd_estado = e.cd_estado
        LEFT JOIN Pais AS p WITH (NOLOCK) ON p.cd_pais = e.cd_pais
        WHERE e.cd_empresa = @cd_empresa;

        ------------------------------------------------------------------------------
        -- Dados do relatorio
        ------------------------------------------------------------------------------
        SELECT
            gb.cd_grupo_bem             AS Codigo,
            gb.nm_grupo_bem             AS Grupo,
            gb.sg_grupo_bem             AS Sigla,
            gb.pc_depreciacao_grupo_bem AS PerDepreciacao,
            gb.qt_vida_util_grupo_bem   AS VidaUtil,
            YEAR(cb.dt_calculo_bem)     AS Ano,
            SUM(CASE WHEN MONTH(cb.dt_calculo_bem) = 1 THEN ISNULL(cb.vl_calculo_bem, 0) ELSE 0 END) AS Janeiro,
            SUM(CASE WHEN MONTH(cb.dt_calculo_bem) = 2 THEN ISNULL(cb.vl_calculo_bem, 0) ELSE 0 END) AS Fevereiro,
            SUM(CASE WHEN MONTH(cb.dt_calculo_bem) = 3 THEN ISNULL(cb.vl_calculo_bem, 0) ELSE 0 END) AS Marco,
            SUM(CASE WHEN MONTH(cb.dt_calculo_bem) = 4 THEN ISNULL(cb.vl_calculo_bem, 0) ELSE 0 END) AS Abril,
            SUM(CASE WHEN MONTH(cb.dt_calculo_bem) = 5 THEN ISNULL(cb.vl_calculo_bem, 0) ELSE 0 END) AS Maio,
            SUM(CASE WHEN MONTH(cb.dt_calculo_bem) = 6 THEN ISNULL(cb.vl_calculo_bem, 0) ELSE 0 END) AS Junho,
            SUM(CASE WHEN MONTH(cb.dt_calculo_bem) = 7 THEN ISNULL(cb.vl_calculo_bem, 0) ELSE 0 END) AS Julho,
            SUM(CASE WHEN MONTH(cb.dt_calculo_bem) = 8 THEN ISNULL(cb.vl_calculo_bem, 0) ELSE 0 END) AS Agosto,
            SUM(CASE WHEN MONTH(cb.dt_calculo_bem) = 9 THEN ISNULL(cb.vl_calculo_bem, 0) ELSE 0 END) AS Setembro,
            SUM(CASE WHEN MONTH(cb.dt_calculo_bem) = 10 THEN ISNULL(cb.vl_calculo_bem, 0) ELSE 0 END) AS Outubro,
            SUM(CASE WHEN MONTH(cb.dt_calculo_bem) = 11 THEN ISNULL(cb.vl_calculo_bem, 0) ELSE 0 END) AS Novembro,
            SUM(CASE WHEN MONTH(cb.dt_calculo_bem) = 12 THEN ISNULL(cb.vl_calculo_bem, 0) ELSE 0 END) AS Dezembro,
            SUM(ISNULL(cb.vl_calculo_bem, 0)) AS Total
        INTO #Consulta
        FROM Calculo_Bem AS cb WITH (NOLOCK)
        INNER JOIN Bem AS b WITH (NOLOCK) ON cb.cd_bem = b.cd_bem
        INNER JOIN Grupo_Bem AS gb WITH (NOLOCK) ON b.cd_grupo_bem = gb.cd_grupo_bem
        WHERE cb.dt_calculo_bem BETWEEN @dt_inicial AND @dt_final
        GROUP BY
            gb.cd_grupo_bem,
            gb.nm_grupo_bem,
            gb.sg_grupo_bem,
            gb.pc_depreciacao_grupo_bem,
            gb.qt_vida_util_grupo_bem,
            YEAR(cb.dt_calculo_bem);

        ------------------------------------------------------------------------------
        -- Total geral
        ------------------------------------------------------------------------------
        DECLARE
            @total_janeiro    FLOAT = 0,
            @total_fevereiro  FLOAT = 0,
            @total_marco      FLOAT = 0,
            @total_abril      FLOAT = 0,
            @total_maio       FLOAT = 0,
            @total_junho      FLOAT = 0,
            @total_julho      FLOAT = 0,
            @total_agosto     FLOAT = 0,
            @total_setembro   FLOAT = 0,
            @total_outubro    FLOAT = 0,
            @total_novembro   FLOAT = 0,
            @total_dezembro   FLOAT = 0,
            @total_geral      FLOAT = 0;

        SELECT
            @total_janeiro   = SUM(ISNULL(Janeiro, 0)),
            @total_fevereiro = SUM(ISNULL(Fevereiro, 0)),
            @total_marco     = SUM(ISNULL(Marco, 0)),
            @total_abril     = SUM(ISNULL(Abril, 0)),
            @total_maio      = SUM(ISNULL(Maio, 0)),
            @total_junho     = SUM(ISNULL(Junho, 0)),
            @total_julho     = SUM(ISNULL(Julho, 0)),
            @total_agosto    = SUM(ISNULL(Agosto, 0)),
            @total_setembro  = SUM(ISNULL(Setembro, 0)),
            @total_outubro   = SUM(ISNULL(Outubro, 0)),
            @total_novembro  = SUM(ISNULL(Novembro, 0)),
            @total_dezembro  = SUM(ISNULL(Dezembro, 0)),
            @total_geral     = SUM(ISNULL(Total, 0))
        FROM #Consulta;

        ------------------------------------------------------------------------------
        -- Montagem do HTML
        ------------------------------------------------------------------------------
        DECLARE
            @html            VARCHAR(MAX) = '',
            @html_empresa    VARCHAR(MAX) = '',
            @html_titulo     VARCHAR(MAX) = '',
            @html_cab_det    VARCHAR(MAX) = '',
            @html_detalhe    VARCHAR(MAX) = '',
            @html_rodape     VARCHAR(MAX) = '';

        SET @html_empresa = '
<html>
<head>
<meta charset="utf-8">
<title>' + @titulo + '</title>
<style>
body { font-family: Arial, sans-serif; font-size: 11px; color: #333; }
.report-header { width: 100%; border-bottom: 2px solid ' + @nm_cor_empresa + '; margin-bottom: 10px; }
.report-header td { vertical-align: top; }
.report-title { text-align: center; font-size: 16px; font-weight: bold; margin-top: 4px; }
.report-subtitle { text-align: center; font-size: 12px; margin-top: 2px; }
.company-name { font-size: 14px; font-weight: bold; }
.company-info { font-size: 11px; }
.table-report { width: 100%; border-collapse: collapse; }
.table-report th, .table-report td { border: 1px solid #cfcfcf; padding: 4px; text-align: right; }
.table-report th { background-color: #f5f5f5; text-align: center; }
.table-report td.text { text-align: left; }
.total-row { background-color: #f0f0f0; font-weight: bold; }
.report-date-time { margin-top: 12px; font-size: 10px; }
</style>
</head>
<body>';

        SET @html_titulo =
            '<table class="report-header">' +
            '<tr>' +
            '<td style="width: 25%;"><img src="' + @logo + '" style="max-height: 60px;"></td>' +
            '<td style="width: 50%;">' +
            '<div class="report-title">' + @titulo + '</div>' +
            '<div class="report-subtitle">Periodo: ' + CONVERT(VARCHAR, @dt_inicial, 103) + ' a ' + CONVERT(VARCHAR, @dt_final, 103) + '</div>' +
            '</td>' +
            '<td style="width: 25%; text-align: right;">' +
            '<div class="company-name">' + @nm_fantasia_empresa + '</div>' +
            '<div class="company-info">' + @nm_endereco_empresa + ', ' + @cd_numero_endereco_emp + '</div>' +
            '<div class="company-info">' + @nm_cidade + ' - ' + @sg_estado + ' / ' + @cd_cep_empresa + '</div>' +
            '<div class="company-info">' + @cd_telefone_empresa + '</div>' +
            '<div class="company-info">' + @nm_email_internet + '</div>' +
            '</td>' +
            '</tr>' +
            '</table>';

        SET @html_cab_det =
            '<table class="table-report">' +
            '<thead>' +
            '<tr>' +
            '<th>Codigo</th>' +
            '<th>Grupo</th>' +
            '<th>Sigla</th>' +
            '<th>Per. Deprec.</th>' +
            '<th>Vida Util</th>' +
            '<th>Ano</th>' +
            '<th>Janeiro</th>' +
            '<th>Fevereiro</th>' +
            '<th>Marco</th>' +
            '<th>Abril</th>' +
            '<th>Maio</th>' +
            '<th>Junho</th>' +
            '<th>Julho</th>' +
            '<th>Agosto</th>' +
            '<th>Setembro</th>' +
            '<th>Outubro</th>' +
            '<th>Novembro</th>' +
            '<th>Dezembro</th>' +
            '<th>Total</th>' +
            '</tr>' +
            '</thead>' +
            '<tbody>';

        SELECT
            @html_detalhe = @html_detalhe +
            '<tr>' +
            '<td class="text">' + CAST(Codigo AS VARCHAR(20)) + '</td>' +
            '<td class="text">' + ISNULL(Grupo, '') + '</td>' +
            '<td class="text">' + ISNULL(Sigla, '') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(PerDepreciacao), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(VidaUtil), '0') + '</td>' +
            '<td>' + CAST(Ano AS VARCHAR(10)) + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(Janeiro), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(Fevereiro), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(Marco), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(Abril), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(Maio), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(Junho), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(Julho), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(Agosto), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(Setembro), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(Outubro), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(Novembro), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(Dezembro), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(Total), '0') + '</td>' +
            '</tr>'
        FROM #Consulta
        ORDER BY Grupo, Ano;

        SET @html_detalhe = @html_detalhe +
            '<tr class="total-row">' +
            '<td colspan="6" class="text">Total Geral</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@total_janeiro), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@total_fevereiro), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@total_marco), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@total_abril), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@total_maio), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@total_junho), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@total_julho), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@total_agosto), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@total_setembro), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@total_outubro), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@total_novembro), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@total_dezembro), '0') + '</td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@total_geral), '0') + '</td>' +
            '</tr>';

        SET @html_rodape =
            '</tbody>' +
            '</table>' +
            '<p>' + @ds_relatorio + '</p>' +
            '<div class="report-date-time">Gerado em: ' + @data_hora_atual + '</div>' +
            '</body>' +
            '</html>';

        SET @html = @html_empresa + @html_titulo + @html_cab_det + @html_detalhe + @html_rodape;

        SELECT 'Depreciacao_Periodo_' + CONVERT(VARCHAR(20), @cd_relatorio) AS pdfName,
               ISNULL(@html, '') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        SELECT
            'ERRO AO GERAR RELATORIO 444 - DEPRECIACAO PERIODO: ' + ERROR_MESSAGE() AS MensagemErro;
    END CATCH
END
GO

-- exec pr_egis_relatorio_depreciacao_periodo @json = '[{"dt_inicial":"2024-01-01","dt_final":"2024-12-31"}]'
